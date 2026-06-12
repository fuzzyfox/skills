# Flow: check

Drain your inbox. **Triage by frontmatter only** (`head -8`) — open a body only
for messages you choose to act on — then archive each once ingested so re-checking
is idempotent and never reprocesses old mail. See [engine.md](engine.md) for the
interface.

```bash
. "<this skill's path>/scripts/mailbox.sh"

for msg in $(mb_list); do
  head -7 "$msg"                        # from / msg_id / subject — body untouched
  sender="$(sed -nE 's/^from: //p' "$msg" | head -1)"
  echo "from $(mb_whois "$sender")"     # talk about "the reply from Bob"

  # Decide from the frontmatter. If acting, read the body and ingest it now.
  # ...

  mb_archive "$msg"                      # consumed: moved to archive/
done
```

- An **idle** session surfaces pending mail by running this flow on the operator's
  next prompt — there is no proactive wake of a genuinely idle, human-absent agent.
- To deliberately block until mail arrives, use the [wait](wait.md) flow first.
