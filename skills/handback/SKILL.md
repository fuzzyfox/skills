---
name: handback
description: Return your work to the parent agent that spawned you by producing a handoff and sending it back through the mailbox. Use when you are a spawned/child session that has finished (or reached a checkpoint on) a side-quest and the operator wants the findings returned to the originating session.
argument-hint: What are you handing back?
license: MIT
metadata:
  author: William Duyck
  version: "0.2"
---

The mailbox `reply` flow with the recipient fixed to **your parent** — the `from`
of your message-zero, the bootstrap handoff you drained on launch.

1. Find your message-zero — the message whose `subject` begins `spawn:`, in your
   `archive/` (or `inbox/` if still unread):

   ```bash
   zero="$(grep -rlE '^subject: spawn:' "$(mb_dir "$(mb_resolve_self)")"/{archive,inbox} 2>/dev/null | head -1)"
   ```

2. Run the mailbox `reply` flow against `$zero` — compose the return body per the
   mailbox `compose` rules and stream it in. It sends home, threaded to your
   parent. Confirm to the operator what was sent and to whom (`mb_whois` for the
   parent's friendly name).

If there is no `spawn:` message-zero you were not created with a return channel, so
there is no parent — use `dispatch` to send to a named peer instead.

If your handoff asks the parent to do any further mailbox work, name the **flow**
("`check` your inbox", "`reply` to thread back"), never the `mb_*` engine functions
— the flow doc carries the discipline a bare function name would leave behind.
