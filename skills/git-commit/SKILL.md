---
name: git-commit
description: Creates git commits with a Gitmoji-prefixed Conventional Commit subject and changelog-aware messaging. Use when the user asks to create a commit, draft or refine commit text, choose a commit type or scope, map changes to Keep a Changelog categories, or add the best Gitmoji to a commit subject.
license: MIT
metadata:
  author: William Duyck
  version: "3.0"
---

# Git Commit

## Quick start

Use this subject format:

```text
<gitmoji> <type>[optional scope][!]: <description>
```

Example:

```text
✨ feat(auth): add password reset emails
```

## Workflows

### Drafting a commit message

1. Inspect staged and unstaged changes plus recent commit subjects.
2. Identify the dominant user-visible intent. Split into multiple commits when one diff mixes unrelated intents.
3. Choose a Conventional Commit `type`, optional `scope`, and `!` only for real breaking changes.
4. Prefix the subject with the single most appropriate Gitmoji. Prefer one Gitmoji, not a chain.
5. Write an imperative subject focused on the change outcome, not a file-by-file summary.
6. Keep the full subject concise. Prefer 72 characters or fewer after the Gitmoji when practical.
7. Add a body only when it improves clarity. Use it to explain why, impact, rollout notes, or migration details.
8. Add footers only when relevant, such as `BREAKING CHANGE:`, issue refs, or trailers.

### Keep a Changelog alignment

- Favor wording that can be promoted into human changelog entries.
- Optimize for notable outcomes: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- Do not dump raw commit logs into changelog-style prose.
- Call out deprecations, removals, and breaking changes explicitly.

### Selection rules

- Default to `feat` for net-new behavior and `fix` for bug fixes.
- Use `docs`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `style`, or `revert` when they better match the primary intent.
- Use `!` and a `BREAKING CHANGE:` footer when compatibility changes need migration guidance.
- Prefer stable, codebase-recognizable scopes such as package, service, feature, or subsystem names.

## Output contract

- Return one best commit message by default.
- If the user asks for options, return 2-3 distinct subjects.
- When asked to create the commit, produce the final message in ready-to-run form.
- When uncertain between nearby Gitmoji choices, prefer the more general and widely understood option.

## Advanced features

See [REFERENCE.md](REFERENCE.md) for type-to-changelog guidance and Gitmoji selection.

See [EXAMPLES.md](EXAMPLES.md) for ready-made commit examples.
