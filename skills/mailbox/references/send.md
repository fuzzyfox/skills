# Flow: send

Deliver a message to another agent's inbox, resolving the recipient by their
friendly name. Delivery is atomic (write-then-rename), so the recipient never
reads a half-written message. See [engine.md](engine.md) for the interface.

Compose the body per [compose.md](compose.md) and stream it straight in — `-`
tells `mb_send` to read the body from stdin, so there is no file to write:

```bash
. "<this skill's path>/scripts/mailbox.sh"

mb_ensure_inbox                          # so the recipient can reply to you
to_id="$(mb_lookup "alice" | cut -f1)"
if [ -z "$to_id" ]; then
  echo "No agent named 'alice'. Known: $(mb_names | paste -sd, -)"
else
  mb_send "$to_id" - "auth flow findings" <<'__MB__'
… body composed per compose.md …
__MB__
fi
```

- The quoted heredoc delimiter (`<<'__MB__'`) keeps the body literal — `$` and
  backticks are not expanded. Pick a delimiter the body itself won't contain.
- The `subject` should be 3–8 words — it is what lets the recipient triage without
  opening the body.
- Never guess an id. If `mb_lookup` finds nothing, list `mb_names` and let the
  operator correct the recipient.
