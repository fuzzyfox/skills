---
name: create-pr
description: Creates GitHub pull requests with repository templates, concise reviewer-focused descriptions, and Linear issue state updates. Use when the user asks to open, create, raise, or publish a PR for a GitHub-backed codebase, especially when branches are Linear issue-prefixed.
license: MIT
metadata:
  author: William Duyck
  version: "1.0"
---

# Create PR

## Quick start

Use this skill for the full PR publishing path:

1. Inspect branch, diff, recent commits, and local context. Assume development and testing already happened unless the user asks otherwise.
2. Detect a repo PR template and preserve its agreed structure.
3. Draft a concise PR body that helps reviewers understand the change without restating the obvious diff.
4. Push the branch and create the PR with `gh pr create`.
5. If the PR is not a draft and the branch starts with a Linear issue key, move that Linear issue to `Code Review` using the Linear MCP.

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

- Explain what changed and why in a few complete sentences.
- Call out non-obvious implementation choices, migrations, config changes, compatibility risks, rollout concerns, and gotchas.
- Link or mention related issues/PRs.
- Include screenshots, recordings, or command output only when they materially help review the change. (Ask the user to provide these when/where relevant)
- Avoid flooding the body with details that are easy to infer from the diff.
- Do not invent testing, risk, or product context.

Use Keep a Changelog-style categories as a thinking aid for key changes: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`. Do not force these labels into a repo template unless they fit naturally.

## Creating the PR

Use `gh pr create` with an explicit title and body. Only create a draft when the operator explicitly asks for one.

After creation, give the user the URL to the PR that was created.

## Linear Update

After a non-draft PR is created successfully:

1. If the branch starts with a Linear issue key, fetch the issue through the Linear MCP.
2. Move the issue to `Code Review`.

Never move Linear for draft PRs. Never update Linear before the GitHub PR exists.

Branch issue keys are only recognized in the form `ABC-123-branch-name`, where the key is at the start of the branch name.
