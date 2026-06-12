# Flow: send

Deliver a `handoff` document to another agent's inbox, resolving the recipient by
their friendly name. Delivery is atomic (write-then-rename), so the recipient
never reads a half-written message. See [engine.md](engine.md) for the interface.

```bash
. "<this skill's path>/scripts/mailbox.sh"

mb_ensure_inbox                          # so the recipient can reply to you
to_id="$(mb_lookup "alice" | cut -f1)"
if [ -z "$to_id" ]; then
  echo "No agent named 'alice'. Known: $(mb_names | paste -sd, -)"
else
  mb_send "$to_id" "$HANDOFF_PATH" "auth flow findings"
fi
```

- `$HANDOFF_PATH` is a document produced by the `handoff` skill (the body).
  `mb_send` wraps it in the envelope (`from`, `msg_id`, `subject`, `to`) for you.
- The `subject` should be 3–8 words — it is what lets the recipient triage without
  opening the body.
- Never guess an id. If `mb_lookup` finds nothing, list `mb_names` and let the
  operator correct the recipient.
