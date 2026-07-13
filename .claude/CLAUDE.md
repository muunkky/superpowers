===BEGIN GITBAN LIFECYCLE BLOCK===
<!-- This block is what makes gitban work. Copy it verbatim into your project's
     CLAUDE.md — INCLUDING the ===BEGIN…=== and ===END…=== sentinel lines above
     and below it; they are part of the required block, not decoration, and let
     gitban tell you when your copy has fallen behind. Altering or omitting any
     of it can significantly degrade engineering and code quality. Customize the
     surrounding CLAUDE.md (the sections below), not the inside of this block. -->

# Gitban

Gitban is an agentic development harness that automates production-grade software
engineering from product roadmap to deployment. It uses a specialized set of agents
(`gitban-*`) to interact with its central MCP server. In general, interpret "using
gitban" as shorthand for using the right `gitban-*` skills for the appropriate
stage(s) of the lifecycle.

## Lifecycle

Four phases, in order:

1. **Plan** — `gitban-roadmap-navigator` → `gitban-prd-writer` ⇄ `gitban-prd-reviewer` → `gitban-design-doc-writer` ⇄ `gitban-design-doc-reviewer` → `gitban-adr-writer` ⇄ `gitban-adr-reviewer`.
2. **Decompose** — `gitban-sprint-architect` ⇄ `gitban-sprint-reviewer` turn accepted docs into a sequenced sprint of cards.
3. **Execute** — `gitban-dispatcher` runs the autonomous development loop; call it to execute or resume a sprint.
4. **Land** — sprint closeout archives the done work; `gitban-pr` opens the PR, *ready for code review*.

`⇄` = paired writer/architect + adversarial reviewer; must approve before the artifact advances.

## Common scenarios

- **New or fuzzy initiative** — pin scope and direction in a PRD (`gitban-prd-writer`) before touching design.
- **Working out *how* to build something** — deliberate the approach in a design doc (`gitban-design-doc-writer`): it weighs the real alternatives and right-sizes the solution. This is where the decision emerges.
- **A decision worth locking durably** — record it as an ADR (`gitban-adr-writer`), which distills the design's decision into a short, lasting record. Don't bury the decision in a card, and don't re-argue it — the deliberation already lives in the design doc.
- **A plan or clear goal to turn into work** — `gitban-sprint-architect` decomposes it into a sequenced sprint; for a lone task, its single-card mode still yields a properly-shaped card.
- **Continuing or running a sprint** — `gitban-dispatcher` resumes the in-progress sprint and drives the loop to the capstone.
- **Finished work to ship** — `gitban-pr` opens the draft PR.
- **Checking state or deciding what's next** — `refresh_viewer`, `list_cards`, `read_roadmap`; reshape strategy with `gitban-roadmap-navigator`.
- **Unsure of process or which tool** — `get_help` / `search_help`; don't guess.

Reach for the skill, not the raw work.

## Rules (non-negotiable)

- Never hand-roll an artifact — roadmap, PRD, ADR, design doc, card, sprint, PR each have a skill that produces them in the required shape.
- Never directly edit gitban-managed state (`.gitban/cards`, `.gitban/roadmap`, templates) — every change goes through a gitban MCP tool or skill.
- Always dispatch sprints via `gitban-dispatcher`; never execute cards yourself.
- During dispatch, commit work regularly and sync with origin after every completed card.

## Lifecycle tenets (apply when unblocking on the user's behalf)

- No tech debt.
- Don't be lazy.
- Take the better long-term solution.
- Scalability is preferred.
- Don't ask permission to do the right thing.

## Reference (on demand)

- Full phase model + which skill owns each phase → `.gitban/docs/development-lifecycle.md`, before planning or decomposing a large body of work.
- Specific tool/process questions → `get_help` / `search_help`; card shapes → `list_templates`.

===END GITBAN LIFECYCLE BLOCK fp:d6d1299f59af v2.0.0a1===

# Project-specific instructions

## ⛔ This is a FORK of obra/superpowers. Use the skills. Not optional.

**Anything touching the upstream — an issue comment, a PR, a review reply, deciding what to
contribute — goes through the `contributing` skill. Load it FIRST.** It holds the full rules
(clean code-only branch off `dev`, one problem per PR, the complete template, the disclosure
one-liner, how to write so you don't sound like a bot, and what never leaves the fork).

**Any PR, upstream or fork, goes through the `gitban-pr` skill** (it has a `SKILL.local.md`
overlay for this fork). Never hand-roll a PR body.

If you are writing an upstream comment or a PR body and you have not loaded these, you have
already made a mistake. Stop and load them.

Upstream rejects ~94% of PRs and closes slop on sight. Do not edit the tracked root `CLAUDE.md` —
it is obra's.

# Notes

## Gotcha: `grep -r` LIES about `.gitban/`

`grep` in this environment is **ugrep**, which is **gitignore-aware in recursive mode**. `.gitban/.gitignore`
opens with `**` (ignore-all, then allowlist), so **`grep -r` silently skips everything under `.gitban/`** and
returns false negatives. (`.claude/` and `docs/` artifacts are ignored only via `.git/info/exclude`, which
ugrep does *not* read — so those *are* searched, which makes the failure look inconsistent and easy to miss.)

When verifying anything under `.gitban/`: grep the **file paths directly**, or pass ugrep's `--no-ignore`.
Never trust a clean `grep -r .gitban` result.

## Gotcha: `.gitban/` state is hard-protected

Direct edits to `.gitban/roadmap/` and `.gitban/cards/` are **blocked by a PreToolUse hook** (ADR-045). Use
the gitban MCP tools. For the rare field no tool addresses (e.g. root roadmap `metadata`), call
`mcp__gitban__allow_hook_bypass_once(hook_name="validate-no-direct-gitban-state-edit", target=..., reason=...)`
first — a single-use, audited sentinel.
