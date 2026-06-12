---
name: spawn
description: Handoff the current conversation and open a new agent session in a fresh tmux window to continue the work, wiring up a mailbox return channel so the child can reply to you. Use when the user wants to spin up a new agent session, fork a side-quest, or delegate work that may report back.
argument-hint: What will the next session be used for?
license: MIT
metadata:
  author: William Duyck
  version: "0.3"
---

`handoff` (the ability) gives you the document; `spawn` is the procedure that
launches a child agent **and**, if you have the `mailbox` ability, wires up a
return channel so it can hand work back. Fire-and-forget by default.

Run `/handoff` (passing any user arguments through) to produce the handoff document.

## With a mailbox

Run the mailbox `setup` flow if you haven't (so you have a stable id to reply to),
then provision and name the child's inbox as you create it. `send` the handoff as the child's **message-zero** to that inbox.

Launch the child (below) with its id, name, and the shared mailbox root — message-zero is its handoff and it bootstraps the rest itself.

When you tell the child how to return work, name the **flow** ("use the `handback`
skill", or "run your mailbox `reply` flow"), never engine functions — the flow doc
carries the discipline a bare function name would strand it without.

- **Fire-and-forget (default)** — return to your work; it's the operator's call to ask for a mailbox check later.
- **Follow to completion** — run the mailbox `wait` flow now, and on mail, action the reply if it's from the session you just spawned.

## Without a mailbox

Pass the handoff document's path as the child's initializing prompt (below).

## Launching the child

Open a new tmux window named with a 2–3 word kebab-case slug from the session's
focus (e.g. `auth-refactor`, `csv-parser`), running the same agent CLI that
invoked this skill. If tmux is unavailable, print the command and ask the operator
to run it manually.

```bash
tmux new-window -n "$TITLE" "$AGENT $PROMPT"
```

`$PROMPT` differs by branch — and `opencode` takes its prompt via `--prompt`, not
as a bare argument, so it gets its own form:

- **Mailbox** — prefix the env contract (`$ROOT` is the shared mailbox root you
  delivered message-zero to, not a hand-rolled default); `$PROMPT` is the bootstrap
  instruction (*"use your mailbox skill — your first message is your handoff"*):
  - `claude`/`codex`: `AGENT_MAILBOX_DIR='$ROOT' AGENT_MAILBOX_ID='$child_id' $AGENT "$PROMPT"`
  - `opencode`: `AGENT_MAILBOX_DIR='$ROOT' AGENT_MAILBOX_ID='$child_id' opencode --prompt "$PROMPT"`
- **No mailbox** — `$PROMPT` carries the handoff path:
  - `claude`/`codex`: `$AGENT "$HANDOFF_PATH"`
  - `opencode`: `opencode --prompt "Read the handoff document at $HANDOFF_PATH and continue from it."`
