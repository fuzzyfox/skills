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

### Authoring and Output

Use this skill when producing markdown reports, changelogs, or dashboards that need embedded charts.

- **[quickchart](./skills/quickchart/SKILL.md)** - Generate chart images for markdown documents using the QuickChart API, with per-type recipes and a transport-aware build script.

  ```bash
  npx skills add fuzzyfox/skills --skill quickchart
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
