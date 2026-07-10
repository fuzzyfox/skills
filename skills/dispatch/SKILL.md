---
name: dispatch
description: Dispatch work to another agent through the mailbox to a named existing peer, or to a new agent wired to reply to you. Use when the operator says "dispatch to <name>" or "dispatch this to a new agent", optionally refining what to send.
argument-hint: "[to <name>] [— what to send]"
license: MIT
metadata:
  author: William Duyck
  version: "0.3"
---

The mailbox front door for handing work off. Either destination composes the body
per the mailbox [`compose`](../mailbox/references/compose.md) rules and streams it
straight into the `send` flow — no handoff file on disk.

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
   existing peer or a new one → **ask the operator** before doing either — creating
   an agent launches a process, so confirm intent first.

## Send to an existing peer

Run the mailbox `send` flow, resolving the peer by `name`. Confirm to the operator
what was sent and to whom (`mb_whois`). If the peer is `wait`-ing it arrives at
once; otherwise it surfaces when the operator next prompts that session and it runs
`check`.

## Create a new agent

- Mint a child id and ensure its inbox; register a friendly name for it (a common
  given name in the operator's current conversation language).
- `send` the composed handoff to that inbox as message-zero, with the subject
  prefixed `spawn:` — this is the marker the child's `handback` greps to find you
  as its parent, so it is required.
- Launch the child in a fresh tmux window named with a 2–3 word kebab-case slug
  from the focus, running the same agent CLI that invoked this skill. If tmux is
  unavailable, print the command and ask the operator to run it manually.

The child's id travels in its **bootstrap prompt**, not the environment — an agent
reads an inherited env var unreliably and may mint a fresh id, so put the id in the
prompt text the model actually sees. `$child_id` is the id you just provisioned and
`$PROMPT` is the bootstrap prompt, which **must name that id explicitly**, e.g.
*"Use your mailbox skill. Your mailbox id is `<child_id>` and your name is
`<child_name>` — set `AGENT_MAILBOX_ID` to that id, then run your `check` flow; your
first message (subject `spawn:`) is your handoff."* The root is the fixed
`/tmp/agent-mailbox`, so nothing about location is passed. `opencode` takes its
prompt via `--prompt`:

```bash
tmux new-window -n "$TITLE" "$AGENT \"$PROMPT\""
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
