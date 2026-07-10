---
name: changelog
description: Generate a markdown changelog for the changes between a fixed point and HEAD, enriched with issue-tracker context. Use when asked for a changelog, release notes, or a summary of merged work over a commit range or date window.
license: MIT
metadata:
  author: William Duyck
  version: "2.1"
---

Generate a changelog for the changes between a **fixed point** and `HEAD`,
enriched with context from the repo's **issue tracker**. Works for an arbitrary
range, not just a week.

## Process

### 1. Pin the fixed point

Whatever the user named is the fixed point — a commit SHA, branch, tag, `main`,
`HEAD~5`, or a date window (e.g. "last week", "since 2026-02-10"). Pass it
through verbatim. If nothing was given, ask: *"Changelog against
what — a branch, a tag, a commit, or a date window?"* and wait. Do not proceed
without a fixed point.

Capture once:

- `git diff <fixed-point>...HEAD --stat` (three-dot = against the merge-base).
- `git log <fixed-point>..HEAD --oneline` for the commit list.
- For a date window, use `git log --since/--until` and the equivalent
  `gh pr list --search "merged:<range>"`.

### 2. Detect the issue tracker (from environment/context)

Infer it from the repo — don't ask if it's obvious. If genuinely unsure, ask the user which tracker to use, and suggest recording for future runs. 

If there is none, say so and continue from git/PR data alone.

Pull the referenced issues for context (title, type, intent) and use them to
write outcome-focused, user-meaningful entries — not just restated commit
subjects.

### 3. Gather the source of truth

Cross-check git commits, merged PRs (`gh` or a remote equivalent, with their
descriptions), and the issues pulled in step 2. Every commit in the range is
accounted for by a PR or a standalone entry before drafting — no commit silently
dropped.

### 4. Write the changelog

If a **`CHANGELOG.md` already exists, update it in place following that file's
existing conventions** (its headings, versioning, date format, entry style).

Otherwise, default to Keep a Changelog headings:

- `### Added` — new capabilities.
- `### Changed` — behaviour updates.
- `### Fixed` — bug corrections.
- `### Removed` — true deletions only.
- `### Tests` — when test changes are relevant.
- `### Developer Notes` — recommended (see below).

Guidance:

- Group related PRs/issues into user-meaningful themes; avoid one bullet per PR
  unless changes are unrelated.
- **Recommended:** link PR IDs in each entry, e.g.
  `[#1234](https://github.com/<org>/<repo>/pull/1234)`. Cite issue refs too when
  the tracker exposes URLs. One bullet covering several PRs lists them all.

**ALWAYS:** present the user with the draft before saving any changes.

### 5. Developer Notes (recommended)

When useful, close with `### Developer Notes`:

- Scope: **N merged PRs** and **M commits** across the range.
- Diff aggregate: **~X additions**, **~Y deletions**, **Z files** (from
  `git diff --stat` / `--shortstat`).

For a date window, state the dates (`YYYY-MM-DD` to `YYYY-MM-DD`).

## Example skeleton

```markdown
### Added

- Added ... ([#1234](https://github.com/<org>/<repo>/pull/1234), ENG-123).

### Changed

- Changed ... ([#1235](https://github.com/<org>/<repo>/pull/1235)).

### Fixed

- Fixed ... ([#1237](https://github.com/<org>/<repo>/pull/1237)).

### Developer Notes

- Scope (2026-02-10 to 2026-02-17): **21 merged PRs**, **17 commits**.
- Diff aggregate: **~6.1k additions**, **~4.3k deletions**, **305 files**.
```
