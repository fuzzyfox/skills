---
name: create-pr
description: Open, publish, or raise a GitHub pull request. Use when the user asks to create or publish a PR for a GitHub-backed codebase, especially when branches are Linear-issue-prefixed.
license: MIT
metadata:
  author: William Duyck
  version: "1.0"
---

# Create PR

## Quick start

Use this skill for the full PR publishing path:

1. Inspect branch, diff, recent commits, and local context. Assume development and testing already happened unless the user asks otherwise.
2. Draft the PR body (see PR Body).
3. Push the branch and create the PR (see Creating the PR).
4. Move the Linear issue if the PR qualifies (see Linear Update).

If `gh` is unavailable, stop and tell the user it is required. If the Linear MCP update fails, do not try another route; tell the user the tool failed.

## PR Body

Prefer the repository template over any generic structure. Fill existing headings in place, preserving order, checkboxes, prompts, and team-specific wording. Work best-practice content around the template instead of replacing it.

When there is no template, use this compact fallback:

```md
## Summary

## Changes

## Risks / Gotchas

## Related Issues
```

Only add a testing or verification section when it gives reviewers useful context, such as non-obvious manual verification, intentionally uncovered behavior, or changes not covered by unit, feature, or end-to-end tests. If verification is unclear from context and git history, omit it unless the repo template requires it.

Write for reviewers:

- Explain what changed and why in a few complete sentences of plain-English prose, describing behaviour, not code.
- Call out non-obvious implementation choices, migrations, config changes, compatibility risks, rollout concerns, and gotchas.
- Link or mention related issues/PRs.
  - When mentioning Linear issues, ensure they're links to the actual issues, not just the issue IDs
- Include screenshots, recordings, or command output only when they materially help review the change. (Ask the user to provide these when/where relevant)
- Avoid flooding the body with details that are easy to infer from the diff.
- Do not invent testing, risk, or product context.

Use Keep a Changelog-style categories as a thinking aid for key changes: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`. Do not force these labels into a repo template unless they fit naturally.

## Creating the PR

Use `gh pr create` with an explicit title and body. Only create a draft when the operator explicitly asks for one.

After creation, give the user the PR URL.

## Linear Update

After a non-draft PR is created successfully, and only then:

1. If the branch starts with a Linear issue key, fetch the issue through the Linear MCP.
2. Move the issue to `Code Review`.

Move Linear only for non-draft PRs. Branch issue keys are only recognized in the form `ABC-123-branch-name`, where the key is at the start of the branch name.
