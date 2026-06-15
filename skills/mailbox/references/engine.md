# Mailbox engine reference

The single place all protocol logic lives:
[`../scripts/mailbox.sh`](../scripts/mailbox.sh). Source it, then call the `mb_*`
functions. Pure bash + coreutils; `flock` is used when present and silently
skipped when absent.

```bash
. "<this skill's path>/scripts/mailbox.sh"
```

## Interface

| Function | Does |
|---|---|
| `mb_resolve_self` | my wire id (resolve, never recall — env `AGENT_MAILBOX_ID` wins) |
| `mb_ensure_inbox [id]` | create `tmp/ inbox/ archive/` (mode 700) for self |
| `mb_send <to-id> <body-file\|-> [subject] [reply_to]` | atomically deliver; prints filename. `-` reads the body from stdin (stream it in via a heredoc — see [compose.md](compose.md)) |
| `mb_list [id]` | pending inbox paths, chronological |
| `mb_archive <path\|name>` | `mv` inbox → archive (idempotent) |
| `mb_wait [timeout-s] [id]` | block until mail arrives — `fswatch` if installed, else bounded `sleep`-poll; 0 on mail, non-zero on timeout |
| `mb_register [name] [id]` | claim a non-colliding name for self, or for an explicit `id` (naming a child you provisioned); prints name or `collision` |
| `mb_lookup <name>` | name → `<id>\t<inbox>` |
| `mb_names` | list registered names |
| `mb_whois <id>` | id → friendly name |
| `mb_dir <id>` | absolute path of an agent's inbox tree (helper) |

## Root and identity contract

- `AGENT_MAILBOX_DIR` is the mailbox root — default `/tmp/agent-mailbox` — and the
  explicit **parent→child contract**. It always wins.
- **The agent owns its id.** `mb_resolve_self` returns `AGENT_MAILBOX_ID` when set
  — the stable contract — and otherwise mints a one-shot uuid. Establish your id
  once at setup (your harness session id if you can read one, else a minted uuid),
  then pass `AGENT_MAILBOX_ID` on every later call. `mb_lookup <my-name>` recovers
  it without holding it in memory.
- Per-inbox layout (Maildir discipline): `tmp/` = write-then-rename staging,
  `inbox/` = unread, `archive/` = consumed. Read-state is **location, not a flag**.
- `flock` guards registry writes when present; `MB_NO_FLOCK=1` forces the
  (low-contention) lock-free path.

## Message envelope

```yaml
---
from: <sender id>     # required: return address
msg_id: <uuid>        # required: dedup / threading
subject: <3-8 words>  # required: body-free triage
reply_to: <msg_id>    # optional: set when answering
to: <recipient id>    # misdelivery tripwire only
---
```

- No `created` field — file **mtime** is authoritative.
- The recipient is the **directory** the file lands in, not a frontmatter field.
- Filename: `<YYYYMMDDThhmmssZ>-<8hex>-<subject-slug>.md` — lexical sort ==
  chronological; the 8 hex (from `msg_id`) guarantee uniqueness under parallel
  writers; the slug often answers triage without even reading the frontmatter.
