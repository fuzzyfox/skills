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

## Wire contract

The root/identity contract, the message envelope, and the filename rule are the
wire protocol — see **[protocol.md](protocol.md)**, its single source of truth. The
engine is one implementation of it. The only engine-specific knob: `flock` guards
registry writes when present, and `MB_NO_FLOCK=1` forces the (low-contention)
lock-free path.
