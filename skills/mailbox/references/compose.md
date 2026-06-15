# Composing a message body

What to put in the body you stream into a `send` or `reply`. The engine wraps it
in the envelope (`from`, `subject`, threading) for you — this is only the prose the
recipient reads.

Write a handoff: enough for a fresh agent to continue the work without your
scrollback. Summarise where things stand, what is decided, and what is left open.

- **Don't duplicate other artifacts.** Reference PRDs, plans, ADRs, issues,
  commits, and diffs by path or URL — never paste their contents.
- **Tailor to the ask.** If the operator named a focus (a `what`, e.g. *"just the
  failing tests"*), scope the body to it.
- **Suggest the skills the recipient should run next**, if any.
- **Name flows and skills, never engine helpers.** When you ask the recipient to
  do mailbox work, say *"`reply` via your mailbox skill"* or *"run your `check`
  flow"* — never an `mb_*` function. The flow doc carries the discipline (archive
  after ingest, resolve by name, root reconciliation) that a bare function name
  would strand them without.

Stream it straight into the flow's `mb_send … - …` heredoc — there is no file to
write.
