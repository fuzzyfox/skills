---
name: spawn
description: Handoff the current conversation and open a new Claude instance in a fresh tmux window to continue the work. Use when the user wants to spin up a new agent session from the current one.
argument-hint: What will the next session be used for?
license: MIT
metadata:
  author: William Duyck
  version: "0.2"
---

Run `/handoff` (passing any user arguments through) to produce the handoff document.

Open it in a new tmux window using a 2–3 word kebab-case slug derived from the session's focus as the window name (e.g. `auth-refactor`, `csv-parser`), and the same agent CLI that invoked this skill (e.g. `claude`, `codex`, or `opencode`).

```
tmux new-window -n "$TITLE" "$AGENT $HANDOFF_PATH"
```

If tmux is unavailable, print the path and prompt the user to run it manually.

