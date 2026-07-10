---
name: commit
description: Commit staged changes as a Gitmoji-prefixed Conventional Commit. Use when the user asks to create, draft, or refine a commit message, or to prepare squash-merge commit text.
license: MIT
metadata:
  author: William Duyck
  version: "3.1"
---

## Quick start

Use this subject format:

```text
<gitmoji> <type>[optional scope][!]: <description>
```

Example:

```text
✨ feat(auth): add password reset emails
```

## Drafting a commit message

1. Inspect staged and unstaged changes plus recent commit subjects.
2. Group every staged change under exactly one user-visible intent; if any change does not fit that intent, split it into its own commit before writing text.
3. Choose a Conventional Commit `type`, optional `scope`, and `!` only for real breaking changes.
4. Prefix the subject with the single most appropriate Gitmoji.
5. Write an imperative subject focused on the change outcome, not a file-by-file summary.
6. Keep the full subject concise. Prefer 72 characters or fewer after the Gitmoji when practical.
7. Add a body only when it improves clarity — to explain the why behind the change.
8. Add footers only when relevant, such as `BREAKING CHANGE:`, issue refs, or trailers.

## Output contract

- Return one best commit message by default.
- If the user asks for options, return 2-3 distinct subjects.
- When asked to create the commit, produce the final message in ready-to-run form.

## Reference

See [REFERENCE.md](REFERENCE.md) for Conventional Commit rules, Keep a Changelog mapping, and Gitmoji selection.

See [EXAMPLES.md](EXAMPLES.md) for ready-made commit examples.
