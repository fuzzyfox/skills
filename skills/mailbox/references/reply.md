# Flow: reply

Answer a message you are holding: a `send` addressed to that message's `from`,
threaded via `reply_to` so the conversation can be followed. See
[engine.md](engine.md) for the interface.

`$MSG` is the path of the message you are replying to (e.g. from `mb_list`).
Compose the body per [compose.md](compose.md) and stream it in via `-`:

```bash
. "<this skill's path>/scripts/mailbox.sh"

sender="$(sed -nE 's/^from: //p'   "$MSG" | head -1)"
mid="$(   sed -nE 's/^msg_id: //p' "$MSG" | head -1)"

mb_send "$sender" - "re: auth flow" "$mid" <<'__MB__'
… body composed per compose.md …
__MB__
```

- The 4th argument sets `reply_to` in the new message's envelope.
- Use `mb_whois "$sender"` to refer to the recipient by name to the operator.
- `handback` is this flow with the recipient fixed to your parent; `dispatch` is
  the plain `send` flow to an operator-named peer.
