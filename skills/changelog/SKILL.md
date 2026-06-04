---
name: changelog
description: Generate a markdown changelog for the changes between a fixed point and HEAD, enriched with issue-tracker context. Use when asked for a changelog, release notes, or a summary of merged work over a range or time window. Pass through whatever the user names as the base (SHA, branch, tag, main, HEAD~5, or a date window); detect the issue tracker from the repo's environment; follow Keep a Changelog headings; update an existing CHANGELOG.md in place when one is present.
license: MIT
metadata:
  author: William Duyck
  version: "2.0"
  sources:
    - Matt Pocock, skills/in-progress/review (fixed-point mechanic)
---

# Changelog

Generate a changelog for the changes between a **fixed point** and `HEAD`,
enriched with context from the repo's **issue tracker**. Works for an arbitrary
range, not just a week.

## Process

### 1. Pin the fixed point

Whatever the user named is the fixed point — a commit SHA, branch, tag, `main`,
`HEAD~5`, or a date window (e.g. "last week", "since 2026-02-10"). Don't be
opinionated; pass it through. If nothing was given, ask: *"Changelog against
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

- **git** for commit coverage, messages, and diff stats.
- **`gh`** (or remote equivalent) for the merged PR list and PR descriptions.
- **issue tracker** for the "why" behind each change.

Cross-check PRs, issues, and commits before drafting.

### 4. Write the changelog

If a **`CHANGELOG.md` already exists, update it in place following that file's
existing conventions** (its headings, versioning, date format, entry style).
Match what's there rather than imposing the format below.

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
- Keep section placement honest (capabilities → Added, behaviour → Changed…).
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
