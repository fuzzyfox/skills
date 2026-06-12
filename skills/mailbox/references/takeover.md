# Flow: takeover

Adopt an **existing** mailbox identity — become "Alice" instead of registering a new
name. Because the agent owns its id (it is just `AGENT_MAILBOX_ID`), taking over is
nothing more than resolving the existing id and carrying it for this session. The
inbox, the registered name, and the address other agents already use all stay put,
so pending mail and future sends keep flowing to whoever currently *is* Alice.

When you reach for this:

- **Crash / resume** — a session died and a fresh one should resume its mailbox.
- **Operator screen-mapping** — the operator wants "the agent on screen 2" to be
  Alice, and tells that session: *"take over Alice's mailbox."*

The functions this flow needs (full interface in [engine.md](engine.md)):

| Function | Does |
|---|---|
| `mb_lookup <name>` | name → `<id>\t<inbox>` (the identity you are adopting) |
| `mb_ensure_inbox [id]` | ensure the maildir exists (it normally already does) |

## Steps

```bash
. "<this skill's path>/scripts/mailbox.sh"

id="$(mb_lookup "alice" | cut -f1)"
if [ -z "$id" ]; then
  echo "No mailbox named 'alice'. Known: $(mb_names | paste -sd, -)"
  # Nothing to take over — run the setup flow to register fresh instead.
else
  export AGENT_MAILBOX_ID="$id"        # adopt it — and carry it all session
  mb_ensure_inbox                      # idempotent; recreates the tree if GC'd
  echo "I am now 'alice' (id $AGENT_MAILBOX_ID)."
fi
```

Then run the [check](check.md) flow to drain any mail that piled up while the
mailbox was unattended.

Already know the raw id (e.g. a crash/resume where you still have your old id)?
Skip the lookup — `export AGENT_MAILBOX_ID=<id>` is the whole of it.

## Caveats

- **No eviction, no liveness.** Identity is not locked and liveness is structurally
  unobservable (an idle agent runs no loop; the registry `pid` is a passive hint).
  Takeover does not kick out a previous holder — if two live sessions both hold
  Alice they will race on her inbox. The operator is responsible for ensuring the
  prior session has exited or yielded before handing the identity over.
- The registry entry (name → id) is unchanged, so no rename or re-registration is
  needed; the stale `pid` is harmless.
