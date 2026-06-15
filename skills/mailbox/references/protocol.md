# Mailbox wire protocol

The raw on-disk contract. [`scripts/mailbox.sh`](../scripts/mailbox.sh) is one
implementation of these rules — but the protocol *is* the filesystem, so any
agent, operator, or harness can participate by following this document with
nothing but a shell and coreutils. Every rule here is observable filesystem state;
there is no hidden coordinator.

## 1. Root

```
root = ${AGENT_MAILBOX_DIR:-/tmp/agent-mailbox}
```

`AGENT_MAILBOX_DIR` always wins and is the explicit parent→child contract: a
parent and child rendezvous by being given the same root. Create it `0700` so its
contents stay private inside a sticky, world-writable `/tmp`:

```bash
mkdir -p -m 700 "$root"
```

## 2. Per-inbox layout (Maildir discipline)

Each participant owns one directory named by its **id** (see §6):

```
<root>/<id>/
  tmp/        # write-then-rename staging
  inbox/      # pending messages   (unread == present here)
  archive/    # consumed messages  (read == moved here, never mutated)
<root>/registry.json
```

Create all three `0700`:

```bash
mkdir -p -m 700 "$root/$id/tmp" "$root/$id/inbox" "$root/$id/archive"
```

**Read-state is location, not a flag.** A message is unread iff it is in `inbox/`.
Consuming it means `mv` to `archive/`. There is no third "in-progress" state and
exactly one owner per inbox.

## 3. Message = envelope + body

A message is a UTF-8 Markdown file: a tiny YAML frontmatter envelope, a blank
line, then the body (a `handoff` document). Field order is fixed so a reader can
`head` the first few lines:

```
---
from: <sender id>     # REQUIRED — the return address
msg_id: <uuid>        # REQUIRED — unique; archival, dedup, threading
subject: <3-8 words>  # REQUIRED — enables body-free triage
reply_to: <msg_id>    # OPTIONAL — present only when answering a prior message
to: <recipient id>    # misdelivery tripwire only (the directory is the real address)
---

<markdown body…>
```

Rules:

- **No `created` field.** The file's **mtime** is the authoritative timestamp.
- The recipient is the **directory the file lands in**, not the `to` field. `to`
  exists only so a misdelivery can be detected.
- `msg_id` is any unique token; a UUID is conventional
  (`uuidgen` / `/proc/sys/kernel/random/uuid`).
- Triage by reading **only the frontmatter** (`head -8`). Open the body solely for
  messages you choose to act on.

## 4. Filename

```
<YYYYMMDDThhmmssZ>-<8hex>-<subject-slug>.md
```

e.g. `20260611T211003Z-a1b2c3d4-auth-flow-findings.md`. Construction:

- **timestamp**: `date -u +%Y%m%dT%H%M%SZ`. Lexical sort == chronological.
- **8hex**: the first 8 hex characters of `msg_id` (strip non-hex, lowercase).
  Guarantees uniqueness under parallel writers sharing a second.
- **slug**: `subject` lowercased, every run of non-`[a-z0-9]` collapsed to a single
  `-`, leading/trailing `-` trimmed. Often answers triage without even a `head`.

## 5. Delivery is atomic (write-then-rename)

Never write directly into a recipient's `inbox/` — a reader could `head` a
half-written file. Stage in the recipient's `tmp/`, then `mv` into `inbox/`. A
`mv` within one filesystem is atomic, so the message appears whole or not at all:

```bash
name="<filename from §4>"
dst="$root/$to/inbox/$name"
tmp="$root/$to/tmp/$name"

mkdir -p -m 700 "$root/$to/tmp" "$root/$to/inbox"
{
  printf -- '---\n'
  printf 'from: %s\n'    "$self"
  printf 'msg_id: %s\n'  "$msg_id"
  printf 'subject: %s\n' "$subject"
  # printf 'reply_to: %s\n' "$reply_to"   # only when answering
  printf 'to: %s\n'      "$to"
  printf -- '---\n\n'
  cat "$body_file"
} > "$tmp"
mv -f "$tmp" "$dst"
```

`$body_file` can be `-` to read the body from stdin (`cat -`), so a sender can
stream composed text straight in without writing a file first.

**Consume** (archive) idempotently — re-archiving an already-moved file is a no-op,
not an error:

```bash
base="$(basename "$msg")"
mkdir -p -m 700 "$root/$self/archive"
[ -f "$root/$self/inbox/$base" ] && mv -f "$root/$self/inbox/$base" "$root/$self/archive/$base"
```

## 6. Identity — the agent owns its id

An id is the **wire address** (the inbox directory name). The agent is responsible
for choosing a **stable** id and then providing it on every call via the
`AGENT_MAILBOX_ID` environment variable:

1. **`$AGENT_MAILBOX_ID`**, when set, is the address. It is the explicit
   parent→child contract (a parent passes it to a spawned child at launch) and the
   way a peer agent carries its own id across calls.
2. When it is unset, the agent **establishes** an id once, at setup:
   - prefer the **harness session id** if the agent can read one (e.g. an
     env/handle the harness exposes) — opaque and naturally stable;
   - otherwise **mint a UUID** (`uuidgen` / `/proc/sys/kernel/random/uuid`).
   The agent then uses that id for the rest of the session by setting
   `AGENT_MAILBOX_ID` on each mailbox command.

The agent carrying its own opaque id is a deliberate, low-risk trade: the id is
not invented from semantic memory, and it can always be **recovered without
recall** by looking up the agent's own registered name (§7) → its `id`. The engine
will mint a one-shot UUID if asked to resolve with no `AGENT_MAILBOX_ID` set, but
that value is only useful if the agent captures and reuses it.

Forks re-mint by default — a fork getting a fresh address is correct. Adopting a
parent's mailbox would be an explicit, separate action.

## 7. Registry and naming

A single `<root>/registry.json` is an object keyed by **friendly name**, so lookup
and uniqueness are O(1):

```json
{
  "bob":   {"id": "…", "harness": "claude", "inbox": "<root>/…/inbox", "pid": 1234, "created": "2026-06-11T21:10:03Z"},
  "alice": {"id": "…", "harness": "codex",  "inbox": "<root>/…/inbox", "pid": 5678, "created": "2026-06-11T21:11:40Z"}
}
```

Rules:

- The agent **generates its own name** — a common given name in the operator's
  current conversation language. To claim it, check the name is not already a key;
  if it is, that is a **collision** — pick another name and retry. Otherwise add the
  entry and write the file back as valid JSON.
- `pid` is a **passive hint only**; nothing depends on it for correctness. There is
  no heartbeat — an idle agent runs no loop, so liveness is structurally
  unobservable.
- Hand-editing is permitted by this protocol but discouraged: prefer the engine's
  `mb_register`/`mb_lookup`/`mb_whois`/`mb_names`, which keep the file valid and
  reduce the error surface for weaker models.

### Concurrency

Registry **writes** are the only mutation that needs care under parallel writers.
Take an exclusive lock when `flock` is available, and accept the lock-free path
otherwise (contention is low — one short read-modify-write per setup):

```bash
( flock 9; …read-modify-write registry.json… ) 9> "$root/.registry.lock"
```

Inbox delivery needs no lock: distinct filenames (§4) plus atomic rename (§5) mean
concurrent senders to one inbox never collide.

## 8. Wake-up is out of band

Delivery is solved completely by this protocol. **Noticing** a delivery is not —
an idle agent is a process blocked on stdin and runs no loop. So:

- A session that deliberately waits holds its **turn open** on a watcher, always
  timeout-bounded. Prefer, in order: the harness's own turn-blocking capability
  (e.g. Claude Code's `Monitor`); then **`fswatch -1`** on the inbox dir when it is
  installed (wakes on the first change); then a bounded **`sleep`-poll** over
  `test -n "$(ls "$root/$self/inbox")"`. The reference engine's `mb_wait` provides
  the latter two — `fswatch` when present, the poll fallback otherwise.
- An idle session simply **drains its inbox** (§5 consume + §3 triage) on the
  operator's next prompt.
- Proactively waking a genuinely idle, human-absent agent is an explicit non-goal.

## 9. Lifecycle / GC

The root lives in `/tmp` and is reclaimed by the OS temp cleaner (macOS
`tmp_cleaner` ~daily at a few days' age; Linux `systemd-tmpfiles` / tmpfs wipe on
reboot). Self-pruning is a feature: dead inboxes and stale registry entries
evaporate. The one hazard — a pending reply pruned after days of idleness — is an
abandoned workflow; point `AGENT_MAILBOX_DIR` at a durable path to opt out.
