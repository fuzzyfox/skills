---
name: dispatch
description: Send a handoff document to a named peer agent through the mailbox. Use when the operator says "dispatch to <name>" (optionally with a refinement of what to send) to hand work to another already-running agent session that has registered a mailbox name.
argument-hint: dispatch to <name> [— what to send]
license: MIT
metadata:
  author: William Duyck
  version: "0.1"
---

The mailbox `send` flow to a **named peer** — bridges two independently-started
sessions once each has set up its mailbox.

1. Parse the operator's request into a recipient `name` and an optional `what` (a
   refinement of the handoff, e.g. *"just the failing tests"*).
2. Run `/handoff`, passing `what` through, to produce the document to send.
3. Run the mailbox `send` flow, resolving the peer by `name`. Make sure your own
   inbox exists first so the peer can reply.
4. Confirm to the operator what was sent and to whom. If the peer is `wait`-ing it
   arrives at once; otherwise it surfaces when the operator next prompts that
   session and it runs `check`.

If no mailbox is registered under `name`, list the known names (`mb_names`) so the
operator can correct it — never guess an id.
