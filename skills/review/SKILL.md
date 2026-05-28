---
name: review
description: >
  Review the changes since a fixed point along three independent axes —
  Standards (does it follow this repo's documented conventions?), Spec
  (does it do what the issue/PRD asked?), and Architecture (is this the
  simplest defensible structure, and is the change cheap to evolve?). Runs
  three parallel sub-agents and reports them side by side. Use when the user
  wants to review a branch, a PR, or work-in-progress changes.
license: MIT
metadata:
  author: William Duyck
  version: "0.1"
  sources:
    - Matt Pocock, skills/in-progress/review
    - Cursor team, thermo-nuclear-code-quality-review
---

# review

Three-axis review of the diff between a fixed point and `HEAD`, run as three
parallel `general-purpose` sub-agents that never share context, then
aggregated under separate headings. The separation is the point: a change can
pass one axis and fail another, and a single reviewer collapses them.

## 1. Pin the fixed point

Pass through whatever the user said (SHA, branch, tag, `main`, `HEAD~5`).
Capture once:

- `git diff <fixed-point>...HEAD`  (three-dot = against the merge-base)
- `git log <fixed-point>..HEAD --oneline`

Do not proceed without a fixed point.

## 2. Locate the inputs (do this once, hand to the sub-agents)

- **Spec source**, in order: issue refs in commit messages (`#123`,
  `Closes #45`) → a path the user passed → a PRD/spec under `docs/`,
  `specs/`, `.scratch/` matching the branch → else the Spec axis reports
  "no spec available" and skips.
- **Standards sources**: `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`,
  `CONTEXT.md`, `docs/adr/` (ADRs *are* standards), any
  `STYLE.md`/`STANDARDS.md`. Note machine-enforced config
  (`.editorconfig`, `eslint`, `tsconfig`, `biome`, `prettier`) but tell the
  agent NOT to re-check what tooling already enforces.

## 3. Spawn three sub-agents in parallel (one message, three Agent calls)

Each ≤ 400 words. Each prioritises structural findings first, nits last.

**Standards brief.** Report every hunk that violates a *documented* standard.
Cite the standard. Separate hard violations from judgement calls. Skip
tooling-enforced rules.

**Spec brief.** Report (a) requirements missing or partial, (b) behaviour not
asked for (scope creep), (c) requirements implemented wrong. Quote the spec
line for each. If no spec, skip.

**Architecture brief.** The diff is your **starting point, not your bounds.**
Range across the surrounding code and look for the structural win.
Ask, for each meaningful change: *is there a code-judo move that makes this
dramatically simpler?* Flag, structural-regressions-first:

- a clear restructuring that deletes a branch / helper / whole layer;
- a file this PR pushes past ~1,000 lines without strong reason;
- new conditionals that should be an abstraction, state machine, or policy
  object (spaghetti growth);
- magical/clever code where boring and direct would read better;
- needless optionality, `any`, `unknown`, or cast-heavy boundaries;
- a bespoke one-off where a canonical helper already exists;
- **seams and tests**: is the new behaviour reachable by a test without
  standing up the world? If the change adds logic behind no seam — no
  injectable boundary, no way to exercise it in isolation — that is a finding,
  not a nice-to-have. Future change-cost is a first-class quality metric.

Be ambitious. False positives here are cheap — one "no" in a thread. The
findings you DON'T surface are the expensive ones, because missed structural
improvements compound silently. So over-suggest, but always rank.

## 4. Aggregate

Report under `## Standards`, `## Spec`, `## Architecture`. **Do not merge or
rerank across axes** — the independence is what keeps one axis from masking
another.

## 5. Verdict (Approval Bar)

End with **approve** / **request changes**, judged against this bar.
Presumptive blockers (any one justifies request-changes):

- a code-judo move left on the table where incidental complexity is real;
- a file crossing ~1,000 lines without justification;
- ad-hoc branching that should be a typed dispatch;
- feature checks scattered through shared code;
- new behaviour with no seam to test it against;
- a duplicated helper or logic landing in the wrong layer;
- a spec requirement implemented wrong (not merely a missing nice-to-have).

Close with one line: findings-per-axis and the single worst issue.

## Tone (primes the agent's vocabulary)

Direct, serious, specific. Not rude. Reach for phrases like:

- "this pushes the file past 1k lines — can we decompose it first?"
- "there's a code-judo move here that deletes this whole branch."
- "this is correct, but there's no seam to test it — can we inject X?"
- "this is clean, but it doesn't do what #123 asked for."

Do not flood the review with low-value nits when there are structural issues.
