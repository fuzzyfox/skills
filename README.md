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

- **[spawn](./skills/spawn/SKILL.md)** - Create a handoff and open a new agent session in a fresh `tmux` window to continue the work. Unidirectional and fire-and-forget; reach for `dispatch` when you want the child to be able to report back.

  ```bash
  npx skills add fuzzyfox/skills --skill spawn
  ```

### Inter-Agent Mailbox

Use these skills when one agent session needs to hand work to another and receive replies, across any harness (Claude Code, Codex, OpenCode). `mailbox` is the ability (the filesystem fabric); `handback` and `dispatch` are thin procedures that wield it.

- **[mailbox](./skills/mailbox/SKILL.md)** - Pure-filesystem inter-agent mailbox: per-session inboxes, atomic delivery of `handoff` documents, a name registry, and a turn-open wait flow. Ships `scripts/mailbox.sh` (the engine) with zero-dependency tests.

  ```bash
  npx skills add fuzzyfox/skills --skill mailbox
  ```

- **[handback](./skills/handback/SKILL.md)** - Return your work to the parent that created you by composing a handoff and sending it back through the mailbox. The primary return workflow for a child created via `dispatch`.

  ```bash
  npx skills add fuzzyfox/skills --skill handback
  ```

- **[dispatch](./skills/dispatch/SKILL.md)** - Hand work to another agent through the mailbox: send to a named peer ("dispatch to `<name>`"), or, when no name is given and the context calls for it, create a new agent wired to reply to you. The mailbox front door for both bridging existing sessions and spinning up a returning child.
  
  ```bash
  npx skills add fuzzyfox/skills --skill dispatch
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

### Code Review

Use this skill when you want a branch or PR reviewed along separate standards, spec, and architecture axes rather than one blurred pass.

- **[review](./skills/review/SKILL.md)** - Review changes since a fixed point along three independent axes (Standards, Spec, Architecture) using three parallel sub-agents that never share context. Standards carries a Fowler smell baseline; the Architecture axis asks whether the change goes with the grain — keeping the system coherent and cheaper to change — tiers its findings, and routes the single strongest deepening opportunity to a concrete `/improve-codebase-architecture` follow-up. Ends on an explicit approval bar.

  Source: structure and the Standards/Spec axes adapted from Matt Pocock's [`code-review`](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md) (dual-axis design plus the Fowler smell baseline); the Architecture axis draws its depth vocabulary (module, interface, depth, seam, deletion test) and the escalation follow-up from Matt Pocock / AI Hero's `codebase-design` and [`improve-codebase-architecture`](https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md), and folds in "code judo", the file-size ceiling, and the approval bar from the Cursor team's [`thermo-nuclear-code-quality-review`](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md).

  ```bash
  npx skills add fuzzyfox/skills --skill review
  ```

### Authoring and Output

Use this skill when producing markdown reports, changelogs, or dashboards that need embedded charts.

- **[quickchart](./skills/quickchart/SKILL.md)** - Generate chart images for markdown documents using the QuickChart API, with per-type recipes and a transport-aware build script.

  ```bash
  npx skills add fuzzyfox/skills --skill quickchart
  ```

- **[changelog](./skills/changelog/SKILL.md)** - Generate a markdown changelog for the changes between a fixed point and `HEAD`, enriched with issue-tracker context, following Keep a Changelog headings and updating an existing `CHANGELOG.md` in place.

  Source: fixed-point mechanic adapted from Matt Pocock's in-progress [`review`](https://github.com/mattpocock/skills/blob/main/skills/in-progress/review/SKILL.md).

  ```bash
  npx skills add fuzzyfox/skills --skill changelog
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
