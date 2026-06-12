# Flow: wait

Deliberately hold the turn open until mail arrives, then run [check](check.md).
Every wait is **timeout-bounded**; the operator bails by interrupting (Esc/Ctrl-C),
never by typing.

The functions this flow needs (full interface in [engine.md](engine.md)):

| Function | Does |
|---|---|
| `mb_resolve_self` | my wire id (`AGENT_MAILBOX_ID` if set, else a one-shot mint) |
| `mb_dir <id>` | absolute path of an agent's inbox tree (helper) |
| `mb_wait [timeout-s] [id]` | block until mail arrives (fswatch or sleep-poll); 0 on mail, non-zero on timeout |

This is **capability-described, not tool-named** — use what your harness offers,
best first. The condition you are waiting on is "my inbox is non-empty":

1. **Turn-blocking capability** (Claude Code: the `Monitor` tool) — block the turn
   directly on the condition, then `check`. This removes turn churn where present:

   ```bash
   . "<this skill's path>/scripts/mailbox.sh"
   inbox="$(mb_dir "$(mb_resolve_self)")/inbox"
   # Monitor condition: test -n "$(ls "$inbox")"
   ```

2. **Otherwise call `mb_wait`** — the engine blocks for you, using `fswatch -1` on
   your inbox when it is installed (wakes on the first change) and a bounded
   `sleep`-poll fallback otherwise. Each call is timeout-bounded; re-issue it next
   turn for a longer wait. `MB_POLL_INTERVAL` tunes the fallback; `MB_NO_FSWATCH=1`
   forces it.

   ```bash
   . "<this skill's path>/scripts/mailbox.sh"
   if mb_wait 540; then
     :   # mail arrived — fall through to check
   else
     :   # timed out — re-issue next turn, or stop
   fi
   ```

Then run the [check](check.md) flow to ingest what arrived.

Waking a genuinely idle, human-absent agent is an explicit **non-goal** — that
needs send-keys or a polling daemon, both rejected.
