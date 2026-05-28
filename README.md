# William Duyck Skills

[![skills.sh](https://skills.sh/b/fuzzyfox/skills)](https://skills.sh/fuzzyfox/skills)

Canonical skill catalog and maintenance workspace for the skills I author and the external skill sources I install from directly.

This repository is designed to work with the `skills` CLI so the catalog can be installed from a local path, GitHub repo, or repo URL.

## Goals

- Keep authored skills in one installable catalog.
- Track external skill sources and exact skill names with clear provenance.
- Document external providers that are part of my local skill set even when their skills are not copied into this repo.
- Preserve a clean separation between versioned catalog content and local agent install directories.

## Skills

### Handoff and Session Continuation

Use these skills when you want to package the current session for another agent or continue the work in a fresh session.

- **[handoff](./skills/handoff/SKILL.md)** - Compact the current conversation into a handoff document for another agent to pick up.

  Source: adapted from Matt Pocock.

  ```bash
  npx skills add fuzzyfox/skills --skill handoff
  ```

- **[spawn](./skills/spawn/SKILL.md)** - Create a handoff and open a new agent session in a fresh `tmux` window so work can continue in parallel or with a clean context.

  ```bash
  npx skills add fuzzyfox/skills --skill spawn
  ```

### Delivery

Use this skill when implementation is done and you want to produce a clean commit message that matches the repo's intent and changelog semantics.

- **[git-commit](./skills/git-commit/SKILL.md)** - Create git commits with a Gitmoji-prefixed Conventional Commit subject and changelog-aware messaging.

  ```bash
  npx skills add fuzzyfox/skills --skill git-commit
  ```

Use this skill when implementation is ready to publish and you want a GitHub PR that follows the repository template, gives reviewers the right context, and updates a linked Linear issue.

- **[create-pr](./skills/create-pr/SKILL.md)** - Create GitHub pull requests with repository templates, concise reviewer-focused descriptions, linked Linear issues, and issue state updates.

  ```bash
  npx skills add fuzzyfox/skills --skill create-pr
  ```

### Authoring and Output

Use this skill when producing markdown reports, changelogs, or dashboards that need embedded charts.

- **[quickchart](./skills/quickchart/SKILL.md)** - Generate chart images for markdown documents using the QuickChart API, with per-type recipes and a transport-aware build script.

  ```bash
  npx skills add fuzzyfox/skills --skill quickchart
  ```

### Communication Modes

Use this skill when you want responses stripped to the bone and an alarm raised on bloated prompts.

- **[desert-mode](./skills/desert-mode/SKILL.md)** - Ruthless token-minimization mode with a "token police" prompt-length check and an oasis exception for safety-critical replies.

  Source: adapted from Rob Conery, ["The Token Police"](https://bigmachine.io/articles/ai/the-token-police); escape route inspired by Matt Pocock's `caveman`.

  ```bash
  npx skills add fuzzyfox/skills --skill desert-mode
  ```

## Install All Skills

Install everything from this repository:

```bash
npx skills add fuzzyfox/skills --all
```

List available skills without installing:

```bash
npx skills add fuzzyfox/skills --list
```

Use `--copy` if you want copied files instead of symlinks.


## Licensing

Authored content in this repository is MIT licensed.

Third-party skills referenced by this repository keep their upstream licenses.
