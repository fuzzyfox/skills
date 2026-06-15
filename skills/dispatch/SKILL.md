---
name: dispatch
description: Hand work to another agent through the mailbox — send to a named existing peer, or, when no name is given and the context calls for it, create a new agent wired to reply to you. Use when the operator says "dispatch to <name>" or "dispatch this to a new agent", optionally refining what to send.
argument-hint: dispatch [to <name>] [— what to send]
license: MIT
metadata:
  author: William Duyck
  version: "0.2"
---

The mailbox front door for handing work to another session. Two destinations
behind one verb: an **existing** peer named by the operator, or a **new** agent you
create and wire to reply to you. Either way the body is composed per the mailbox
[`compose`](../mailbox/references/compose.md) rules and streamed straight into the
`send` flow — there is no handoff file.

Make sure your own inbox exists first (mailbox `setup` flow) so the recipient can
reply.

## Choose the destination

Parse the operator's request into a recipient `name` (if any) and an optional
`what` (a refinement of the handoff, e.g. *"just the failing tests"*). Then:

1. **Named, and it resolves** (`mb_lookup`) → send to that peer.
2. **Named, but no match** → list the known names (`mb_names`) and let the operator
   correct it. Never guess an id.
3. **No name, and the context clearly calls for a fresh delegate** → create a new
   agent (below).
4. **No name, and it's ambiguous** — you can't tell whether the operator meant an
   existing peer or a new one → **ask the operator** before doing either. Creating
   an agent launches a process; don't do it on a guess.

## Send to an existing peer

Run the mailbox `send` flow, resolving the peer by `name`. Confirm to the operator
what was sent and to whom (`mb_whois`). If the peer is `wait`-ing it arrives at
once; otherwise it surfaces when the operator next prompts that session and it runs
`check`.

## Create a new agent

Provision and name the child's inbox, deliver its **message-zero**, then launch it:

- Mint a child id and ensure its inbox; register a friendly name for it (a common
  given name in the operator's current conversation language).
- `send` the composed handoff to that inbox as message-zero, with the subject
  prefixed `spawn:` — this is the marker the child's `handback` greps to find you
  as its parent, so it is required.
- Launch the child in a fresh tmux window named with a 2–3 word kebab-case slug
  from the focus, running the same agent CLI that invoked this skill. If tmux is
  unavailable, print the command and ask the operator to run it manually.

`$ROOT` is the shared mailbox root, `$child_id` the id you just provisioned, and
`$PROMPT` the bootstrap instruction (*"use your mailbox skill — your first message
is your handoff"*). `opencode` takes its prompt via `--prompt`:

```bash
tmux new-window -n "$TITLE" "AGENT_MAILBOX_DIR='$ROOT' AGENT_MAILBOX_ID='$child_id' $AGENT \"$PROMPT\""
# opencode: … $AGENT --prompt "$PROMPT"
```

Then choose:

- **Fire-and-forget (default)** — return to your work; it's the operator's call to
  ask for a mailbox check later.
- **Follow to completion** — run the mailbox `wait` flow now, and on mail, action
  the reply if it's from the agent you just created.

## Both paths

Anything you write into the body for the recipient to act on should name the
**flow** it ought to run (*"reply via your mailbox `reply` flow"*, *"use the
`handback` skill"*) — never the `mb_*` engine functions — so the surrounding flow
discipline travels with the instruction.
