# PRD-002: Subagent release is missing from the workflows that dispatch subagents

> **Status**: Draft (rev 2) | **Date**: 2026-07-13 | **Author**: cameron (muunkky fork)
> **Roadmap**: m1/s1/codex-integration/codex-subagent-lifecycle
> **Upstream target**: obra/superpowers issue [#1927](https://github.com/obra/superpowers/issues/1927) (@gwokhou, OPEN, unclaimed, 0 comments, no PR)

## Problem Statement

Under the Codex harness, a subagent that has finished its work keeps holding its concurrency slot
until it is explicitly closed. This is not an inference — it is what OpenAI's shipped tool spec tells
the model, verbatim, in the `close_agent` description:

> "Close an agent and any open descendants when they are no longer needed, and return the target
> agent's previous status before shutdown was requested. **Completed agents remain open and count
> toward the concurrency limit until closed.** Don't keep agents open for too long if they are not
> needed anymore."
>
> — `codex-rs/core/src/tools/handlers/multi_agents_spec.rs`, line 296, at tag `rust-v0.142.5`
> ([permalink](https://github.com/openai/codex/blob/rust-v0.142.5/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L296))

So waiting on an agent and reading its result does not release anything; only `close_agent` does.
Superpowers already knows this — it is written down, in one line, in
`skills/using-superpowers/references/codex-tools.md`.

But that is the only place in `skills/` it appears. The three skills that actually *dispatch* a
subagent and consume its result — `subagent-driven-development`, `dispatching-parallel-agents`, and
`requesting-code-review` — never mention releasing, closing, or otherwise finishing with a subagent
anywhere in their steps. A controller running any of them does exactly what the skill tells it to do:
dispatch, wait, consume the result, act on it, move on. Nothing in the text it is following says there
is anything left to do with the finished agent. Each completed subagent therefore holds a slot until
closed; with a finite concurrency limit, a long SDD plan — which dispatches an implementer, a task
reviewer, and often a fixer *per task*, plus a final whole-branch reviewer — accumulates unreleased
slots.

The rule exists, but it lives in a platform-reference footer the controller has no reason to re-read
mid-loop, while the workflow bodies — the text it is actually executing — are silent. That gap is the
problem.

*Provenance.* Two independently-checkable facts, and one thing we did **not** do:

- **The Codex mechanism is a cited fact**, quoted above from the pinned tool spec and verified against
  the source at that tag, not taken on report.
- **The superpowers-side gap is verified first-hand** on `upstream/dev` at tip
  `096e15aa736d2e920fb7f1e2c954604f02ebbdb0` (2026-07-10), grepped 2026-07-13:
  `git grep -ln close_agent -- skills/` returns exactly one file,
  `skills/using-superpowers/references/codex-tools.md`. The three dispatch skills named above contain
  zero mentions of `close_agent` or any release step.
- **We have not observed slot exhaustion in a live Codex session; no one on the issue has.** The
  reporter observed the tool surface, not an exhausted pool. We do not have a Codex multi-agent
  environment to drive. This sentence must be carried verbatim into the PR body rather than implying a
  session we did not run.

## What "Solved" Means

A controller executing any of the three dispatch workflows, on a harness where subagents hold a finite
resource until released, is **structurally required by the steps it is following** to release each
subagent once it is finished with it — without having had to read a platform-reference footnote to
know that.

The yardstick, and the invariants that must survive alongside it:

- Read any of the three `SKILL.md` files end to end as a controller does — dispatch → wait → consume →
  act → next. The release step is *in that path*, at the point where the controller is done with the
  agent, not appended as a note elsewhere in the document.
- **The release condition is stated, not just the release.** A controller that intends to turn an agent
  back for more input must not be told to close it (see Features, and the `send_input` exception below).
- `skills/using-superpowers/references/codex-tools.md` is **not touched** — open PR
  [#1926](https://github.com/obra/superpowers/pull/1926) owns that file.
- No new dependencies (Superpowers is zero-dependency by design).
- The diff is confined to the three workflow bodies and stays minimal: this is a missing step, not a
  rewrite of tuned skill content.

## Principles & Assumptions

**Guiding principles**

- **The workflow bodies are cross-harness, and stay harness-neutral. This is a constraint, not an open
  question.** These three SKILLs are read by controllers on Claude, Codex, OpenCode and others. The repo
  already has a layer for harness-specific tool names — the `using-superpowers/references/*` platform
  files — and `close_agent` belongs there, where it already is. Importing a Codex tool name into
  cross-harness prose would invert that structure, and it is not on the table. (What *is* open is how a
  neutral rule reaches the concrete tool — see the Open Decision.)
- **This is tool-mapping correctness, not behavior tuning.** The rule already exists in-repo and is
  already stated as mandatory. We are putting it where the controller executes. The framing must stay
  that narrow, because the bar upstream holds *tuned skill content* to (eval evidence) is different from
  the bar it holds platform-mapping fixes to — and this repo closes reword-for-compliance passes.
- **One problem, one PR.** #1927 and only #1927. No adjacent Codex cleanup, no touching #1926's file, no
  drive-by edits.

**Assumption** (one, and it is the honest one)

- *The workflow bodies are the text a controller actually follows mid-loop; the reference footer is not.*
  This is the whole causal claim, and it is an assumption, not a fact. If controllers reliably re-read
  `codex-tools.md` at each task boundary, the rule is already delivered and the gap is cosmetic. We
  assume they do not, because nothing in any of the three workflows points them back to it at the
  moment it matters. What breaks if it's wrong: the change is inert rather than harmful.

## Current State

Verified on `upstream/dev` @ `096e15aa736d2e920fb7f1e2c954604f02ebbdb0` (2026-07-10), grepped 2026-07-13:

| File | State |
| :--- | :--- |
| `skills/using-superpowers/references/codex-tools.md` | Enables `spawn_agent` / `wait_agent` / `close_agent`, and states the rule (line 10) — but **scoped to one skill**: *"When using **subagent-driven-development**, you should always close implementer and reviewer subagents when they have finished all their work."* It says nothing about the other two dispatch skills. **Owned by open PR #1926 — do not touch.** |
| `skills/subagent-driven-development/SKILL.md` | Dispatches an implementer, a task reviewer, and fix subagents per task, plus a final whole-branch reviewer. Zero mentions of closing/releasing — not in The Process, not in Handling Implementer Status, not in Red Flags. |
| `skills/dispatching-parallel-agents/SKILL.md` | Dispatches N agents in parallel, then "Review and Integrate" when they return. Zero mentions of closing/releasing. |
| `skills/requesting-code-review/SKILL.md` | "**2. Dispatch code reviewer subagent** … Dispatch a `general-purpose` subagent" → "**3. Act on feedback**". Consumes the result and ends. Zero mentions of closing/releasing. |
| `skills/executing-plans/SKILL.md` | Not affected — it points at SDD rather than dispatching subagents of its own. |

The delta from here to "solved" is prose in those three bodies — nothing else.

### The turn-back exception is real

The release rule is **not** unconditional, and #1927 says so: close the agent *"unless the controller
intentionally plans to keep that same agent open for follow-up `send_input`."* The Codex spec backs
this at the same tag — `send_input`'s own description tells the model: *"You should reuse the agent by
`send_input` if you believe your assigned task is highly dependent on the context of a previous task."*
(`multi_agents_spec.rs` L143.)

And SDD is full of turn-back paths:

- `NEEDS_CONTEXT` → "Provide the missing context and **re-dispatch**."
- `BLOCKED` → "provide more context and **re-dispatch** with the same model."
- Reviewer ⚠️ items → "treat it as a failed spec review — **send it back to the implementer** and re-review."
- Review loop → "**Implementer (same subagent) fixes them.**"

A blanket "release once the result is consumed" would therefore be **actively wrong** on these paths —
it would tell a controller to close an agent it is about to turn back to. (Note that SDD's own text is
internally ambiguous about whether the turn-back is the same agent or a fresh dispatch: the process
diagram says "Dispatch fix subagent" while the Red Flags section says "Implementer (same subagent)
fixes them." Resolving *that* ambiguity is not this PRD's job and is not in scope — the release rule
must be worded so it is correct either way.)

## Features

Capability (branch): **The workflow a controller executes tells it to release a finished subagent**

| Feature (behavior) | Acceptance |
| :--- | :--- |
| The release obligation is **conditioned on being finished with the agent**, not merely on having read its result | The rule as written tells a controller to release a subagent when it has consumed the result *and does not intend to send that agent further input*; a controller on any of SDD's turn-back paths (`NEEDS_CONTEXT`, `BLOCKED`, reviewer ⚠️ send-back, same-agent fix loop) follows the rule and correctly does **not** close the agent it is about to reuse |
| `subagent-driven-development`'s per-task loop requires releasing each subagent it is finished with | Reading the SKILL's process steps in order, a controller reaches an explicit release step once it is done with an implementer, task reviewer, fixer, or the final whole-branch reviewer — and the same obligation is reflected where the SKILL enumerates what a controller must never do |
| `dispatching-parallel-agents`'s post-dispatch step requires releasing each agent it is finished with | Reading the SKILL's steps in order, a controller reaches an explicit release step after collecting and integrating the parallel agents' results |
| `requesting-code-review`'s dispatch sequence requires releasing the reviewer it is finished with | Reading the SKILL's numbered steps, a controller reaches an explicit release step after acting on the reviewer's feedback |
| The release obligation reads correctly on a harness that has no such concept | A controller on a harness where subagents need no release can follow all three SKILLs without confusion, and no body reads as harness-specific instruction |

Five leaves, and no finer. The concrete tool-to-behavior binding (i.e. *which call* performs the
release on Codex) lives outside these three files and is not a feature of this PRD — see the Open
Decision, which governs how the leaves above are worded.

## Goals & Non-Goals

**Goals**

- Close the gap in #1927: put the release obligation, **with its condition**, into the steps a
  controller actually executes.
- Keep the three cross-harness workflow bodies harness-neutral.
- Keep the diff small enough to be reviewed in one sitting and to survive a scope-creep screen.

**Non-Goals**

- **Editing `references/codex-tools.md`.** Reasonable people would argue the rule "belongs" there and
  that its one-skill scoping should be widened. It is already there, and PR #1926 owns the file. Out of
  scope — and this creates a real hole that the design doc must absorb (see Open Decision).
- **Editing the prompt templates** (`implementer-prompt.md`, `task-reviewer-prompt.md`,
  `code-reviewer.md`). The controller releases the agent; the agent does not release itself.
- **Resolving SDD's same-agent-vs-fresh-dispatch ambiguity** on its turn-back paths. Pre-existing, and a
  separate change. Our wording must simply be correct under either reading.
- **Any other Codex lifecycle work** — notably #1960 (GPT-5.6 subagent behavior). Different problem,
  different PR.
- **Rewording or restructuring any tuned content** in the three SKILLs beyond the addition required here.
- **An eval of the change.** Not because evals are beneath this change — **because we cannot drive a
  Codex multi-agent session, so we cannot eval this.** That is the honest reason, and it is a limitation
  we disclose rather than a standard we are waving away.

## Success Criteria

1. Each of the three `SKILL.md` bodies contains an explicit step, inside its workflow sequence, obliging
   the controller to release a subagent it is finished with. (Stated decision-independently: the *wording*
   is the Open Decision's to fix; the criterion is that the step exists in the executed path, and a reader
   can point to it.)
2. The rule as written is **correct on the turn-back paths**: a controller following it does not close an
   agent it intends to send further input to.
3. `git diff --stat` for the PR shows exactly three files changed, all `SKILL.md`.
4. The prose in all three bodies is correct and actionable for a controller on a harness with **no**
   release concept — it must not read as harness-specific instruction, and must not name a harness's tool.
5. `references/codex-tools.md` is untouched (no conflict with PR #1926).
6. The PR body states, without hedging, that the Codex mechanism is cited from the pinned tool spec, that
   the superpowers-side gap was grep-verified on Linux at a named `dev` tip, and that **we have not
   observed slot exhaustion in a live Codex session; no one on the issue has.**

## Constraints

- **Cross-harness prose** in all three bodies (Claude, Codex, OpenCode, …). Harness neutrality is a hard
  constraint, not a preference.
- **`codex-tools.md` is off-limits** for the duration of PR #1926.
- **Zero new dependencies.**
- **Upstream contribution bar.** ~94% rejection rate; slop, scope creep, speculative fixes, and
  unevidenced edits to tuned skill content are closed on sight. Targets `dev`, never `main`.
- **We cannot drive Codex multi-agent.** Any acceptance requiring an observed released slot is unmeetable
  by us and must not be written into the plan as if it weren't.

## Risks & Open Questions

### Open decision — routed to the design doc, deliberately not resolved here

Harness neutrality is settled (a constraint, above). What is genuinely open is **how a neutral rule in
the workflow body reaches the concrete `close_agent` call** — a controller that reads "release it" must
end up making the right call:

- **(a) A purely harness-agnostic lifecycle rule** in the three bodies — e.g. "once you are finished with
  a subagent and will not send it further input, release it" — relying on the platform reference
  (`codex-tools.md`) to supply the concrete mapping, as it does today.
- **(c) A neutral rule *plus* a pointer** — the body states the neutral obligation and directs the
  controller to its harness's platform reference at the moment it matters, so the mapping is reachable
  from inside the loop rather than only at session start.

(The third candidate we considered — an explicit Codex-named step in the workflow bodies — is **ruled
out** by the neutrality constraint, and is recorded here only so the design doc does not re-open it.)

**The hole option (a) has to answer.** `codex-tools.md`'s rule sentence is scoped to exactly one skill:
*"When using **subagent-driven-development**, you should always close implementer and reviewer
subagents…"*. It says nothing about `dispatching-parallel-agents` or `requesting-code-review`. So under
pure (a), a neutral "release it" added to those two bodies maps to **nothing concrete anywhere** — and
our own Non-Goals forbid the single edit (widening that sentence) that would close the loop. This
probably does **not** change the no-touch call — deferring to PR #1926 on a file it owns is right — but
the design doc **must inherit this and decide what covers `dispatching-parallel-agents` and
`requesting-code-review`**: a pointer (option c), a follow-up PR to `codex-tools.md` once #1926 lands, or
something else. It is the strongest argument against pure (a), and it must not be discovered late.

**Status of the maintainer check-in.** We posted an intent comment on #1927 proposing the
harness-agnostic direction and asking for a sanity check on the framing before building. That reply is
**pending**; if it lands, it is the strongest available input to this decision, and the design doc should
wait for it if it can.

### Risks

- *Maintainer reads this as behavior-tuning of skill content and asks for eval evidence.* Mitigation:
  frame it as platform tool-mapping correctness (the rule already exists in-repo and is already
  mandatory), lead with the pinned tool-spec quotation and the grep, and keep the diff minimal. We cannot
  supply an eval, and say so.
- *The neutral wording fails to actually change controller behavior on Codex* — the controller reads
  "release it" and does not connect it to `close_agent`. This is the substantive risk in the open
  decision, sharpened by the hole above, and is exactly why the decision is routed onward rather than
  assumed.
- *Three files instead of two reads as scope creep.* Mitigation: the third file is named in the issue
  itself (#1927: "possibly `skills/requesting-code-review/SKILL.md` or the Codex reference mapping"), and
  it demonstrably dispatches a `general-purpose` subagent and consumes its result. Excluding it would
  leave the same gap in a site the reporter already pointed at. Say this in the PR.
- *PR #1926 lands first and changes `codex-tools.md` in a way that interacts with our wording.* Low impact
  — we do not touch the file — but the design should re-check its state before the PR opens.

## Roadmap Fit

    m1/s1/codex-integration/
    ├─ codex-native-integration        (done)
    ├─ codex-sessionstart-stability    (done)
    ├─ codex-deferred-tools-docs       (in progress — owns codex-tools.md via PR #1926)
    ├─ codex-subagent-lifecycle        (this PRD — in progress; issue #1927)
    └─ codex-windows-sandbox           (todo)

## Required Documents

| Artifact | Kind | Status | Lands at |
| :--- | :--- | :--- | :--- |
| How a neutral release rule in a cross-harness workflow body reaches the concrete harness tool — (a) vs (c), and what covers `dispatching-parallel-agents` / `requesting-code-review` given the `codex-tools.md` no-touch constraint | design doc | needed | `docs/designs/` |
| **The durable convention**: how harness-specific tool lifecycles are expressed in cross-harness skill bodies (the reusable rule this instance establishes — not a record of "we edited three files") | ADR | needed | `docs/adr/` |

## Related Documents

- Upstream issue [obra/superpowers#1927](https://github.com/obra/superpowers/issues/1927) — the source problem.
- Our intent comment: <https://github.com/obra/superpowers/issues/1927#issuecomment-4956276696> (awaiting maintainer sanity check).
- Open PR [obra/superpowers#1926](https://github.com/obra/superpowers/pull/1926) — owns `references/codex-tools.md`; do not touch that file.
- Codex tool spec, pinned: [`multi_agents_spec.rs` @ `rust-v0.142.5`](https://github.com/openai/codex/blob/rust-v0.142.5/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L296) — `close_agent` (L296) and `send_input` (L143).
- `PRD-001` — prior upstream contribution from this fork; same contribution-bar constraints apply.

---
## Revision History
| Date | Author | Notes |
| :--- | :--- | :--- |
| 2026-07-13 | cameron | Initial draft. |
| 2026-07-13 | cameron | Rev 2 after adversarial review (5 blocking). Added `requesting-code-review` as a third dispatch site (named in the issue; verified it dispatches + consumes). Made the release rule **conditional** on the `send_input` turn-back exception, verified against SDD's turn-back paths and the Codex spec. Promoted the Codex mechanism from "reporter's account" to a cited, pinned quotation; deleted the unsupported "exhausts the pool" claim; kept one honest assumption. Made harness-neutrality a hard constraint (ruling out the Codex-named option) so the open decision is genuinely open, and restated SC4. Surfaced the `codex-tools.md` one-skill-scoping hole that the no-touch constraint creates. Re-scoped the ADR to the durable convention. Named the exact `dev` tip grepped. |
