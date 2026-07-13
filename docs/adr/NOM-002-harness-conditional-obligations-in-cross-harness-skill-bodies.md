# NOM-002: How a cross-harness skill body expresses an obligation only some harnesses have a mechanism for

> **Status**: Proposed | **Date**: 2026-07-13 | **Deciders**: cameron (muunkky fork) | **Distilled from**: [DD-002](../designs/DD-002-subagent-release-in-workflow-bodies.md) (rev 3) | **PRD**: [PRD-002](../prds/PRD-002-codex-subagent-release-in-workflow-bodies.md)

## In Plain Terms (ELI5)

Superpowers' workflow skills are read by controllers on many harnesses, but some obligations exist on
only *some* of them — on Codex a finished subagent keeps holding its concurrency slot until it is closed;
on Claude Code there is nothing to close. This settles how a shared skill body says such a thing: state
the obligation in neutral prose, key it to what the controller intends to do next (not to the workflow's
own status codes), put it at the step where that intent is actually *settled*, and point at the
per-platform reference directory for the concrete tool — never naming the tool in the body. The tradeoff:
a recurring pointer clause, and a rule that leans on a reference layer we have just proven is uneven.

## Context

Superpowers' workflow bodies (`subagent-driven-development`, `dispatching-parallel-agents`,
`requesting-code-review`, …) are executed by controllers on Claude Code, Codex, Gemini CLI, Copilot,
OpenCode, Pi, and Antigravity. Harness-specific tool names are confined to a reference layer at
`skills/using-superpowers/references/<harness>-tools.md`.

That structure has an unaddressed seam: **an obligation that exists on only some harnesses.** Subagent
*release* forced the question — Codex's tool spec tells the model that "Completed agents remain open and
count toward the concurrency limit until closed" (`multi_agents_spec.rs` L296 @ `rust-v0.142.5`), while on
fire-and-forget harnesses the concept has no counterpart. The obligation cannot be named in the body
(that imports a harness tool into cross-harness prose), and leaving it only in the reference layer means
the text the controller actually executes never mentions it.

**The class recurs in-repo today.** `codex-tools.md` alone carries three harness-conditional obligations
(subagent dispatch; `## Environment Detection`; `## Codex App Finishing`) — and they are *not* all solved
the same way. That is why this is a convention and not a footnote to a three-file diff.

PRD-002 fixed the scope and hard-ruled harness-neutrality; DD-002 deliberated the shape and converged.
This ADR records the convention.

## Decision

When a workflow body must express an obligation that only some harnesses have a mechanism for:

**Clause 1 — Key the condition to the controller's own intent, not to the workflow's state machine.**
Ask the controller a question about *itself* that it can always answer ("will I send this agent more
input?"), never one about a status whose meaning the workflow may not pin down.

**Clause 2 — Site the rule where the intent is *determinate*, not merely where the path is guaranteed.**
An unconditionally-executed step at which the controller cannot yet answer clause 1's question is a
**false** site: the rule fires, the answer is "I don't know yet," and the controller does nothing. Both
properties are required, and determinacy is the one that gets skipped.

> **Clause 2a — the exception, when no correct site exists.** Sometimes the workflow has **no step after
> the action at all**, so there is nowhere for a trigger to live and the obligation is **necessarily
> forward-looking**. **The absence of a later step must be demonstrated, not asserted** — this exception
> is the convention's only escape hatch, and it is exactly the one a hurried author will claim without
> looking. Do not pretend it satisfies the siting rule. Place it as late as possible (after the
> last turn-back that could reuse the agent), keep the span short and the agent population singular, and
> **back it with an entry in the prohibition ledger** (`Red Flags`, or whatever list the controller
> re-reads under context pressure). The ledger entry is not decoration: for a forward obligation it is the
> **only** thing that fires at the right moment. And scope the ledger entry to the *agent*, not to the
> enclosing loop — a task-scoped backstop excludes precisely the leftover agent that needed it.

**Clause 3 — Point to the reference layer when, and only when, the mechanism is harness-specific *and*
not *reliably* in the controller's context across the harness's supported configurations.** If it is
harness-specific and out of context, carry an in-body pointer at the moment the rule fires, using the
established construction — *"(see the per-platform tool refs in `../using-superpowers/references/`)"*. If
the mechanism is universal and already in context, state the neutral step and **do not** point.
**When exposure varies by configuration, the out-of-context configuration governs — point.** (Our own
instance is exactly this case: `close_agent` is `ToolExposure::Direct` *without* tool-search and
`Deferred` *with* it, so the bare question "is it in context?" answers **"depends"** — the same
under-determination clause 2 exists to outlaw, resurfacing one clause later.)

Name no harness and no harness tool in the body, in any case.

*The instance:* the release rule is conditioned on *"don't intend to send it further input"* —
deliberately **status-blind** — sited in SDD at the **task boundary**, and carrying the pointer. Five
insertions, three files, ~120 words.

## Rationale

**Clause 1 (intent-keying).** The tempting move is to key release to SDD's four implementer statuses.
It reads beautifully and it is wrong: SDD is internally ambiguous about whether a turn-back reuses the
agent or dispatches a fresh one — its digraph says *"Dispatch fix subagent"*, its Red Flags say
*"Implementer (**same subagent**) fixes them"* — and resolving that is an explicit non-goal. Under the
fresh-dispatch reading a `BLOCKED` implementer is an agent you are **done with**, so a status-keyed rule
would instruct the controller to hold it open forever — manufacturing the exact leak, in the exact skill
the issue is about. An intent-keyed rule is correct under **both** readings.

**Clause 2 (siting) exists because clauses 1 and 3 do not, by themselves, pick a site — and the design
shipped the wrong one twice before this was caught.** DD-002 rev 2 sited SDD's rule at the end of
`## Handling Implementer Status`: unconditionally executed, so it satisfied the path requirement. But the
controller's intent is **undetermined** there — the task review has not run, and the same-subagent reading
says the implementer may yet be sent fix work. So the controller holds the agent, the reviewer returns
clean, and the workflow never asks again. **The rule degrades into silent inaction — the status quo, i.e.
the leak — in the flagship skill.** "Degrades gracefully under ambiguity" was doing unexamined work in the
prior draft: it meant *degrades silently into doing nothing*. The fix is a real tiebreaker, not a
preference: SDD's rule is re-sited to the **task boundary**, the only prose step that is both
unconditional and intent-settled, where implementer, task reviewer and fixers are all provably finished
under **both** readings.

**Clause 2a exists because we then violated clause 2 again, one edit later, *with the clause written
down*.** The rule for SDD's final whole-branch reviewer was sited on a **dispatch-preparation** bullet —
it fired **before the agent it governs existed**: a forward obligation with no re-fire point, exactly the
failure clause 2 was invented to catch. We applied the tiebreaker rigorously to the per-task agents and
missed the one agent left over. And when we looked for a correct site, **there was none**: SDD has no
prose step after the final review at all. So for that agent the obligation is *necessarily* forward-
looking — which is a case the convention did not previously cover, hence clause 2a. The ledger backstop
is the load-bearing half of it: our first attempt at that backstop was **task-scoped**, which by
construction **excluded the final reviewer** — the one agent that depended on it — and the gap was
invisible until someone asked what covered the forward obligation. **An obligation you cannot site
correctly must be priced, not dressed up.** DD-002 says it in terms this ADR endorses: *"Do not claim
Edit 3b is as strong as Edit 3a. It isn't. It is the best available, and it is fenced."*

**Clause 3 (the pointer) is load-bearing on source evidence, not assertion — this is the ADR's central
fact.** The strongest case for the pointer-free alternative was "the Codex controller already has
`close_agent`, whose own description carries the obligation, so the pointer is redundant." **It is false
on exactly the configuration `codex-tools.md` documents:** in `codex-rs/core/src/tools/spec_plan.rs`
(`add_collaboration_tools`, multi-agent v1 branch) @ `rust-v0.142.5`, `close_agent` is registered
`ToolExposure::Deferred` whenever tool-search is enabled — so its name and its obligation-bearing
description are **not in the controller's context when the rule fires**. Without the pointer, the neutral
rule has no path to the tool.

**A second, independent argument for neutrality, from the same function:** the multi-agent **v2** branch
exposes `SpawnAgent, SendMessage, FollowupTask, WaitAgent, InterruptAgent, ListAgents` — and **no
`close_agent` at all**. The release verb is not stable across Codex versions, so naming the tool in the
body (alternative (b)) would have been *actively wrong* on v2 — a version argument, entirely separate from
the cross-harness one.

**The governing counter-example, which sharpens clause 3 rather than defeating it.**
`finishing-a-development-branch` carries `### Step 2: Detect Environment` as a neutral in-body step with
**no pointer** — and `codex-tools.md` points *back at the body*. That is the same class of problem solved
the opposite way, and it is correct: its mechanism is **plain git commands** — universal, already in
context, nothing harness-specific to reach for. Ours is harness-specific, *version*-specific, and
*deferred out of context*. Hence clause 3's two-armed test, which tells the next case which arm it takes.

**The precedent, stated honestly.** `executing-plans/SKILL.md:14` uses the directory-pointer construction
verbatim, and the maintainer's in-flight refactor PR [#1934](https://github.com/obra/superpowers/pull/1934)
(as currently drafted, 2026-07-13) strips self-selling prose from that very sentence while **preserving
the pointer clause**. But it is a *session-start advisory to the human partner*, not a mid-loop
obligation — and `writing-skills/SKILL.md:12` is **not** the same construction (per-*file* links, of which
2 of 4 — `claude-code-tools.md`, `copilot-tools.md` — **do not exist** at `096e15aa`). So the honest claim
is: **we reuse upstream's pointer construction for a new use.** Not "we invent nothing." (The silver
lining is real: `writing-skills:12`'s dead per-file links are the best available argument *for* the
directory form — file links rot; a directory pointer cannot.)

**Key tradeoff:** a recurring pointer clause, and a dependence on the reference layer not being *actively
misleading*, in exchange for a rule that is executable rather than merely true. Full weighing in DD-002
(KDD-1, KDD-2b, KDD-3, KDD-5).

## Consequences

### Positive
- A harness-conditional obligation reaches a concrete tool **from inside the loop**, at a step where the
  controller can actually decide, without any body naming a harness or a tool.
- Correct on harnesses with no such mechanism: the pointer targets a *directory*, always resolves, and a
  controller that finds no obligation for its harness correctly does nothing.
- Survives Codex version drift (v2 drops `close_agent`) and reference-layer incompleteness (a missing
  harness file is a correct no-op).
- Clauses 1–3 generalize past this instance: 1–2 to any obligation sitting near an ambiguous workflow
  state, and 3 demonstrably — its negative arm is supplied by a *live in-repo counter-example*
  (`finishing-a-development-branch`), so its generality is tested rather than asserted.

### Negative (honest)
- **The pointer costs tokens** in every body that carries it, on every read. Small, recurring, cumulative.
- **It depends on the reference layer not being actively misleading — and on Codex today it is.**
  `codex-tools.md`'s rule sentence is scoped to `subagent-driven-development` alone, so a
  `dispatching-parallel-agents` controller that follows our pointer may read that sentence and conclude
  the obligation is **not its own**. That is the pointer *subtracting* compliance relative to no pointer
  at all — a real harm vector, not a hypothetical. (The layer drifts, too: `codex-tools.md`
  cross-references *"finishing-a-development-branch Step 1"* when Detect Environment is Step 2.) Widening
  that sentence is a **scheduled follow-up**, blocked only on PR
  [#1926](https://github.com/obra/superpowers/pull/1926) landing, which owns the file.
- **This is unevaluated behavior-shaping content added to three tuned skills**, in a project whose own
  house rule is that skills are code, not prose. The null hypothesis is not "no effect" — it is **"unknown
  effect."** We cannot rule out impact on the skills' other tuned behaviors.
- Intent-keyed prose is vaguer than a status table, and a future contributor **will** be tempted to
  "improve" it by enumerating statuses. That edit silently reintroduces the bug.
- **A clause-2a obligation is genuinely weaker than a correctly-sited one**, and the convention now says
  so out loud rather than hiding it. It relies on the controller carrying the obligation forward across a
  span, backed only by the prohibition ledger. We price it; we do not claim parity.

### Neutral
- Prose only. No code, no schema, no dependency, no new file. Rollback is a revert.

## Alternatives Considered

Weighed in DD-002 against PRD-002's "solved"; recorded by reference, not re-argued.

- **(a) Neutral rule only, no pointer** — rejected: `close_agent` is `ToolExposure::Deferred` on the
  documented config, so the rule has no path to the tool; and `codex-tools.md`'s coverage is SDD-scoped,
  omitting `requesting-code-review` entirely — even though SDD's own final whole-branch review dispatches
  through RCR's template, so RCR leaks on every SDD run. See DD-002 KDD-1.
- **(b) Name the harness tool in the body** — ruled out by PRD-002's neutrality constraint, and
  independently by version drift: multi-agent v2 exposes no `close_agent`. Recorded so it is not reopened.
- **Status-keyed condition** — inverts under the fresh-dispatch reading. Rejected. DD-002 KDD-3.
- **Site the rule on any unconditionally-executed step** — insufficient; it produced a design that did not
  fix the bug. Rejected in favour of clause 2. DD-002 KDD-2b.
- **Follow-up PR widening the reference file instead of pointing** — leaves the fix incomplete until a
  second PR merges (which may never), and splits one problem across two. Rejected.

## Validation

**What we can prove — structurally.** For any body adopting the convention: the rule sits on an
unconditional path *and* at a point where intent is determinate; it names no harness and no harness tool;
its condition appears as words in the same sentence; the pointer resolves to a real directory. DD-002
§Verification specifies these as binary greps. **Check 10 —
`grep -E 'NEEDS_CONTEXT|BLOCKED|DONE_WITH_CONCERNS'` over added lines — is the standing enforcement** for
the "someone will enumerate the statuses" consequence above, and check 6 fails if SDD's instance count
drops from 3.

**The evidence that clause 2 is load-bearing rather than pedantic — state it plainly.** The siting rule
was violated **twice, by competent authors**: once in the design that invented it, and once *after it was
written down*, one edit later. **Both times it took an adversarial reader to catch, and both times the
defect was silent** — prose that reads correctly and instructs the controller to do nothing. Anyone who
reads this ADR as ceremony should read that sentence first.

**What we cannot prove — the ceiling.** The convention's premise is that a controller reading neutral
prose plus a pointer will follow the pointer and make the right call. **We cannot drive a Codex
multi-agent session. We have not observed a controller calling `close_agent` after reading this prose, nor
a slot held, nor released.** The mechanism is *cited* from Codex's pinned source, not observed; the
superpowers-side gap is grep-verified; the change is verified **structurally, not behaviorally**. No eval
backs it.

**If the premise is wrong**, the change is **inert with respect to release behavior** — and that claim is
narrow, not a clean bill of health: per the Negatives, a misleading reference sentence can make the
pointer *subtract* compliance, and this is unevaluated behavior-shaping content whose effect on the
skills' other tuned behaviors is **unknown**, not null.

**Revisit triggers.**
- Evidence that a controller reads the neutral rule and does not reach the tool → falsifies clause 3's
  premise; reopens the shape question (a mechanism rather than prose).
- `codex-tools.md`'s rule sentence widened post-#1926 → removes the "actively misleading" harm vector, and
  weakens (does not eliminate) clause 3's force, since it never depended on *completeness*.
- A workflow resolving the ambiguity that motivated clause 1 does **not** license status-keying: the
  principle is robustness under ambiguity generally, and the next ambiguous workflow will not announce
  itself.

## Related Decisions

Second ADR in this repo; supersedes nothing. Records the convention DD-002 rev 3 deliberated (KDD-1,
KDD-2b, KDD-3, KDD-5); satisfies PRD-002's second required artifact. Does **not** re-decide PRD-002's
harness-neutrality constraint, which is upstream of this record. Reuses the construction at
`skills/executing-plans/SKILL.md:14` for a new use; `finishing-a-development-branch` `### Step 2` is the
governing counter-example for clause 3's negative arm.

**A correction is owed to obra/superpowers#1927**, where we publicly proposed alternative (a). See DD-002
§Migration & Rollback.

## References

- Design doc (full deliberation): [DD-002](../designs/DD-002-subagent-release-in-workflow-bodies.md) rev 3
- PRD ("solved" + the neutrality constraint): [PRD-002](../prds/PRD-002-codex-subagent-release-in-workflow-bodies.md)
- Upstream issue: [obra/superpowers#1927](https://github.com/obra/superpowers/issues/1927); reference-file PR [#1926](https://github.com/obra/superpowers/pull/1926); maintainer refactor PR [#1934](https://github.com/obra/superpowers/pull/1934) (as drafted 2026-07-13)
- **Deferred exposure (the load-bearing fact):** `codex-rs/core/src/tools/spec_plan.rs`, `add_collaboration_tools` @ `rust-v0.142.5` — `close_agent` registered `ToolExposure::Deferred` under tool-search; v2 branch exposes no `close_agent`
- The obligation itself, cited not observed: [`multi_agents_spec.rs` L296 @ `rust-v0.142.5`](https://github.com/openai/codex/blob/rust-v0.142.5/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L296)
- Precedent and counter-example: `skills/executing-plans/SKILL.md:14`; `skills/writing-skills/SKILL.md:12` (per-file links, 2 of 4 dead); `skills/finishing-a-development-branch/SKILL.md` `### Step 2`
- Roadmap: `m1/s1/codex-integration/codex-subagent-lifecycle`

---
## Revision History
| Date | Status | Notes |
| :--- | :--- | :--- |
| 2026-07-13 | Proposed | Distilled from DD-002 (rev 2) as NOM-002 — the durable convention, not the diff. |
| 2026-07-13 | Proposed | **Rev 2, after ADR review returned REVISE** (verdict: *not ceremony — the class recurs in-repo*). **(B1)** Added **clause 2**, the missing tiebreaker between "site it on the unconditional path" and "key it to intent" — those select *different* sites, and rev 1's convention had no rule to choose; at SDD's `## Handling Implementer Status` the intent is undetermined, so the rule degraded into **silent inaction**, i.e. the leak, in the flagship skill. Named what "degrades gracefully" had been concealing. **(B2)** Instance updated to DD-002 rev 3: five insertions / ~120 words, SDD sited at the **task boundary** with two instances. **(B3)** Clause 3 now rests on **source evidence** — `close_agent` is `ToolExposure::Deferred` under tool-search (`spec_plan.rs` @ `rust-v0.142.5`), so the "the controller already has the tool" case for alternative (a) is false on the documented config; the same function shows v2 exposes **no** `close_agent`, an independent version-drift argument for neutrality. **(S4)** Recorded `finishing-a-development-branch` `### Step 2` as the governing counter-example and generalized clause 3 to its two-armed form (point iff harness-specific *and* out of context). **(S2)** Corrected the overstated precedent — `writing-skills:12` is a different construction with 2 of 4 links dead, and `executing-plans:14` is a session-start advisory; **deleted "invents nothing."** **(S3/S1)** Resolved the completeness/accuracy equivocation (independent of *completeness*, dependent on not being *actively misleading* — which on Codex it is), killed the unqualified "inert, not harmful," and added the missing harm vector: unevaluated behavior-shaping content in tuned skills. **(M3)** Cited check 10 as enforcement. **(M2)** Timestamped the #1934 claim. |
| 2026-07-13 | Proposed | **Rev 3 — added clause 2a, the case the convention did not cover.** The design reviewer applied rev 2's own **clause 2** back against the design and found we had violated it **again, one edit later, with the clause written down**: SDD's final whole-branch reviewer had its rule sited on a **dispatch-preparation** bullet — firing *before the agent it governs existed*. No correct site exists (SDD has no prose step after the final review), so the obligation is **necessarily forward-looking**. Clause 2a records the exception: place it as late as possible, keep the span short and the agent population singular, and **back it with a prohibition-ledger entry scoped to the agent, not the loop** — our first backstop was task-scoped and by construction excluded the very agent that needed it. Endorsed DD-002's posture — an obligation you cannot site correctly is **priced, not dressed up** — and recorded the fact that the siting rule was violated **twice by competent authors, both times silently, both times caught only adversarially**, as the standing answer to any reader who thinks this record is ceremony. Instance unchanged: five insertions, three files, ~120 words. |
| 2026-07-13 | Proposed | **APPROVED by adversarial review.** Three record-only edits, no decision reopened. **(S1)** Clause 3's second arm was itself under-determined — `close_agent` is `ToolExposure::Direct` *without* tool-search and `Deferred` *with* it, so the literal test "is it in context?" answers **"depends"** for our own instance, resurfacing one clause later the exact defect clause 2 exists to outlaw. Narrowed to *"not **reliably** in context across the harness's supported configurations"* and added the tiebreaker: **when exposure varies by config, the out-of-context config governs — point.** **(M1)** Closed clause 2a's abuse vector: **the absence of a later step must be demonstrated, not asserted** — it is the convention's only escape hatch. **(M2)** Positive consequence corrected to clauses **1–3**: clause 3's generality is the one actually *tested*, by a live in-repo counter-example. |
