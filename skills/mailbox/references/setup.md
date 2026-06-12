# Flow: setup

Ensure your inbox exists, claim a friendly name, and tell the operator your name.
This is the one action that lets you participate.

## Engine interface

Source [`../scripts/mailbox.sh`](../scripts/mailbox.sh), then call the `mb_*`
functions — never hand-edit the inbox or registry. The functions this flow needs:

| Function | Does |
|---|---|
| `mb_ensure_inbox [id]` | create `tmp/ inbox/ archive/` (mode 700) for self, or a child `id` |
| `mb_register [name] [id]` | claim a non-colliding name for self, or for a child `id`; prints name or `collision` |
| `mb_lookup <name>` | name → `<id>\t<inbox>` (recover your own id without recall) |
| `mb_whois <id>` | id → friendly name (check whether you are already named) |

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

**If you were spawned, you may already be named.** A parent names the child it
provisions, so check before registering: `mb_whois "$AGENT_MAILBOX_ID"`. If it
returns a name, **adopt it** — you are already in the registry, so just report that
name and skip registration; registering again would create a second entry for the
same id. Only fall through to the registration below if you come back nameless.

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

## Naming a child you provision

When you spawn another agent, you mint its id and create its inbox — so you are the
one code path guaranteed to run. Name it in the same breath, by passing its id to
`mb_register`, so every inbox gains a registry entry the instant it exists and no
nameless mailbox is ever left lying around:

```bash
mb_ensure_inbox "$child_id"             # provision the child's maildir
child_name="$(mb_register "Alice" "$child_id")"
while [ "$child_name" = collision ]; do
  child_name="$(mb_register "Alana" "$child_id")"
done
```

Report the name to the operator ("spawned **Alice**") and tell the child its own
name in its message-zero. On boot the child **adopts** that name (above) rather than
registering a second entry for the same id.
