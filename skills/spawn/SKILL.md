---
name: spawn
description: Spawn a fresh agent session from the current one — hand the conversation off into a new tmux window that continues the work one-way, with no channel back. Use `dispatch` instead when the child must report back.
disable-model-invocation: true
argument-hint: What will the next session be used for?
license: MIT
metadata:
  author: William Duyck
  version: "0.2"
---

Run `/handoff` (passing any user arguments through) to produce the handoff document.

Open it in a new tmux window using a 2–3 word kebab-case slug derived from the session's focus as the window name (e.g. `auth-refactor`, `csv-parser`), and the same agent CLI that invoked this skill.

For `claude` and `codex`, pass the handoff path directly:

```
tmux new-window -n "$TITLE" "$AGENT $HANDOFF_PATH"
```

For `opencode`, instead, start it with an initial prompt that tells it to read the handoff document:

```
tmux new-window -n "$TITLE" "$AGENT --prompt \"Read the handoff document at $HANDOFF_PATH and continue from it.\""
```

Confirm the window opened and report its name to the operator.

If tmux is unavailable, print the path and prompt the user to run it manually.
