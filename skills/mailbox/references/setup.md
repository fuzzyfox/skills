# Flow: setup

Ensure your inbox exists, claim a friendly name, and tell the operator your name.
This is the one action that lets you participate.

## Engine interface

Source [`../scripts/mailbox.sh`](../scripts/mailbox.sh), then call the `mb_*`
functions — never hand-edit the inbox or registry. The functions this flow needs:

| Function | Does |
|---|---|
| `mb_ensure_inbox [id]` | create `tmp/ inbox/ archive/` (mode 700) for self |
| `mb_register [name]` | claim a non-colliding name; prints name or `collision` |
| `mb_lookup <name>` | name → `<id>\t<inbox>` (recover your own id without recall) |

For the full interface, the message envelope, and the root/identity contract, see
[engine.md](engine.md).

**First, establish your stable id.** You own your identity: prefer your harness
session id if you can read one (opaque and naturally stable); otherwise mint a
UUID. Export it as `AGENT_MAILBOX_ID` and **pass it on every mailbox command this
session** so your address never changes. A spawned child already has
`AGENT_MAILBOX_ID` in its launch environment — skip the mint and use it.

```bash
. "<this skill's path>/scripts/mailbox.sh"

# Spawned children inherit AGENT_MAILBOX_ID; peers mint one and carry it.
: "${AGENT_MAILBOX_ID:=$(uuidgen 2>/dev/null | tr 'A-Z' 'a-z' || cat /proc/sys/kernel/random/uuid)}"
export AGENT_MAILBOX_ID
```

Then claim a name. Pick a **common given name in the language you and the operator
are speaking** so it is memorable to them. `mb_register` guarantees uniqueness; on
`collision`, pick another name and retry.

```bash
mb_ensure_inbox
name="$(mb_register "Bob")"            # your chosen name
while [ "$name" = collision ]; do
  name="$(mb_register "Bobby")"        # try another on collision
done
echo "I am '$name' (id $AGENT_MAILBOX_ID)."
```

Report the name to the operator so they can address you ("dispatch to Bob"). If
you ever lose track of your id, recover it without recall: `mb_lookup "$name" | cut -f1`.
