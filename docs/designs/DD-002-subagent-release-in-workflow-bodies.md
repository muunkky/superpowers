# DD-002: Subagent release in the three cross-harness dispatch workflow bodies

> **PRD**: [PRD-002](../prds/PRD-002-codex-subagent-release-in-workflow-bodies.md) | **Date**: 2026-07-13 | **Author**: cameron (muunkky fork)
> **Upstream**: obra/superpowers issue [#1927](https://github.com/obra/superpowers/issues/1927) · targets `dev`
> **Baseline**: `upstream/dev` @ `096e15aa736d2e920fb7f1e2c954604f02ebbdb0`

## Overview

PRD-002 established the problem and settled its scope. Three cross-harness workflow bodies —
`subagent-driven-development` (SDD), `dispatching-parallel-agents` (DPA), and
`requesting-code-review` (RCR) — dispatch subagents, wait, consume their results, act, and move on.
None of them tells the controller that a finished subagent still has to be *released*. On Codex, a
completed agent holds its concurrency slot until it is closed (`multi_agents_spec.rs` L296 @
`rust-v0.142.5`), so a controller that follows these workflows exactly as written accumulates
unreleased agents. The rule exists in the repo — but only in
`skills/using-superpowers/references/codex-tools.md`, a platform-reference footer the controller has
no reason to re-read mid-loop.

**"Solved"** (from the PRD): a controller executing any of the three workflows is *structurally
required by the steps it is following* to release each subagent once it is finished with it — with
the release **conditioned** on not intending to send that agent further input, and without any body
naming a harness or a harness tool.

**The approach this doc chooses.** The PRD routed one open decision here: how a neutral "release it"
in a cross-harness body reaches the concrete `close_agent` call, given that `codex-tools.md` is
off-limits (PR [#1926](https://github.com/obra/superpowers/pull/1926) owns it). We choose **option
(c): a neutral, conditioned release rule in each body, carrying a pointer to the per-platform tool
refs** — using the *exact pointer idiom upstream already uses* in `executing-plans/SKILL.md` for the
same class of problem. Option (a) (rule only, no pointer) is rejected: `codex-tools.md`'s rule
sentence is scoped to SDD alone, so under (a) the rule we add to DPA and RCR maps to nothing
concrete anywhere, and the no-touch constraint forbids the edit that would fix it. **We owe issue
#1927 a correction** — our intent comment there proposed (a).

The change is **five insertions across three files — 13 added lines (RCR +1, DPA +1, SDD +11), zero lines deleted, zero new
headings.** Every added clause is specified verbatim below.

**Two findings from the `codex-rs` source decide the design, and both were nearly missed.** (1)
`close_agent` is registered `ToolExposure::Deferred` on any model with tool-search — **its name and
its obligation-bearing description are not in the controller's context when the rule fires**, which
is what makes the pointer load-bearing rather than redundant (KDD-1). (2) Multi-agent **v2 has no
`close_agent` at all** — it exposes `InterruptAgent` instead — so the release verb is not even stable
across versions, which independently vindicates harness-neutrality. And one finding from SDD's own
control flow: the rule must be sited at the **task boundary**, because that is the only point where
the controller's intent toward its agents is *determinate* (KDD-2b) — an earlier revision of this doc
sited it where the intent is still unknown, and would have **left the leak in place** under one of the
two live readings of SDD.

## Requirements

The implementation is complete when:

1. **R1 — In the executed path.** Each of the three `SKILL.md` bodies contains an explicit release
   step *inside its existing workflow sequence*, at the point where the controller consumes the
   subagent's result. Not in a preamble, not in a new section.
2. **R2 — Conditioned, and reuse-safe by construction.** Every release instance **states the intent
   condition in the same sentence** — that the controller will send that agent no further input. The
   exact wording varies by site (*"unless you intend to send it further input"* where the agent is
   singular; *"you will send none of them further input"* where a set of agents is released at a
   boundary); what R2 requires is the *condition*, not a fixed phrase. No instance keys the condition
   to SDD's implementer statuses (see KDD-3 — that would be *wrong* under one of the two live readings
   of SDD's re-dispatch text). And per KDD-2b, every instance is **sited where that intent is
   determinate**.
3. **R3 — Reflected in SDD's prohibition ledger.** SDD's Red Flags `**Never:**` list carries the
   obligation, **for both agent populations** — the per-task agents and the final whole-branch
   reviewer.
4. **R4 — The neutral rule is reachable to its concrete tool.** Each of the three bodies points the
   controller at `../using-superpowers/references/` at the moment the rule fires.
5. **R5 — Harness-neutral.** No added line names a harness (Codex, Claude, Gemini, OpenCode) or a
   harness tool (`close_agent`, `spawn_agent`, `wait_agent`, `send_input`).
6. **R6 — Minimal, contained diff.** Exactly three files changed, all `SKILL.md`;
   `skills/using-superpowers/**` untouched; no existing sentence deleted or reworded; no new heading
   and no new numbered step.
7. **R7 — Zero new dependencies**, zero new files.

R1/R2 trace to PRD features 1–4; R4/R5 to feature 5; R6/R7 to the PRD's Constraints.

## Current State

Verified against `upstream/dev` @ `096e15aa`.

### The three bodies, at their consumption points

| File | Consumption point (executed path) | Release step today |
| :--- | :--- | :--- |
| `skills/requesting-code-review/SKILL.md` | `**3. Act on feedback:**` — a 4-bullet list ending `- Push back if reviewer is wrong (with reasoning)`. Document then ends the procedure. | none |
| `skills/dispatching-parallel-agents/SKILL.md` | `### 4. Review and Integrate` — `When agents return:` + 4 bullets ending `- Integrate all changes`. | none |
| `skills/subagent-driven-development/SKILL.md` | `## Handling Implementer Status` (implementer returns) → `## Handling Reviewer ⚠️ Items` (task reviewer returns; ends `...before marking the task complete`). Fix subagents and the final whole-branch reviewer are governed from `## Constructing Reviewer Prompts`. | none — not in The Process, not in either Handling section, not in Red Flags |

### The reference layer, and the hole in it

`skills/using-superpowers/references/codex-tools.md` (line 10, **read-only for us**):

> This enables `spawn_agent`, `wait_agent`, and `close_agent` for skills like
> `dispatching-parallel-agents` and `subagent-driven-development`. **When using
> subagent-driven-development, you should always close implementer and reviewer subagents when they
> have finished all their work.**

Two distinct sentences with **different scopes**, and this distinction is the crux of the design:

- The *enabling* sentence names DPA **and** SDD → `close_agent` is on the tool surface for both.
- The *rule* sentence names **SDD only** → the obligation is scoped to one skill.
- **RCR is named in neither.**

**RCR's absence from that file is not merely a documentation hole — it is a live leak, and we can
prove it from SDD's own text.** SDD's process digraph contains the node *"Dispatch final code
reviewer subagent (`../requesting-code-review/code-reviewer.md`)"*, and its Prompt Templates section
says *"Final whole-branch review: use superpowers:requesting-code-review's code-reviewer.md."* **SDD's
final whole-branch review routes through RCR's template.** On Codex that reviewer is a `spawn_agent`
like any other and holds a slot until closed — yet `requesting-code-review` is named **nowhere** in
`codex-tools.md`, not even in the enabling sentence. So the one reviewer that every SDD run dispatches
last, and never releases, is the one governed by the file's biggest blind spot. This is also the real
answer to "three files is scope creep" — RCR is not a third site we went looking for; it is *on SDD's
own critical path*.

So the concrete mapping available to a controller under pure option (a) is:

| Body | Is `close_agent` on its tool surface per the ref? | Does the ref state an obligation for it? | Net under option (a) |
| :--- | :--- | :--- | :--- |
| SDD | yes | yes | **works** |
| DPA | yes | **no — and the rule sentence's SDD scoping can be read as *excluding* DPA** | silent at best, contradictory at worst |
| RCR | not mentioned at all | no | **maps to nothing** |

We cannot widen that sentence: PR #1926 owns the file (PRD Non-Goals).

### The precedent that decides the design

`skills/executing-plans/SKILL.md` L14 — a **cross-harness workflow body** already reaches into the
platform-reference layer, neutrally, with this exact construction:

> ...(Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; **see the
> per-platform tool refs in `../using-superpowers/references/`**).

`skills/writing-skills/SKILL.md` L12 does the same for per-runtime skill paths. So an in-body pointer
to the per-platform refs is **not a new convention** — it is upstream's established one, at the same
directory depth (`skills/<name>/`), and the relative path `../using-superpowers/references/` resolves
correctly from all three of our target skills (verified).

### Test and CI surface

No CI workflows exist (`.github/` holds only `FUNDING.yml`, `ISSUE_TEMPLATE/`,
`PULL_REQUEST_TEMPLATE.md`). Tests are shell scripts under `tests/`; `tests/claude-code/` drives the
real `claude` CLI. Nothing lints or asserts on the *prose* of the three target files. This matters:
**no automated test can validate this change**, and the verification plan says so plainly.

## Target State

The three bodies, at the same consumption points, each carry one neutral release clause. The
reference layer is unchanged and demoted from *source of the rule* to *lookup for the tool name*:

```
  BODY (cross-harness, the text the controller executes mid-loop)
  ┌──────────────────────────────────────────────────────────────────┐
  │ dispatch → wait → consume result → act                            │
  │                                    └─► "release it, unless you'll │
  │                                         send it further input"    │  ← obligation + condition
  │                                         ...(see the per-platform  │     live HERE (new)
  │                                         tool refs in ../using-    │
  │                                         superpowers/references/)  │  ← pointer (new)
  └────────────────────────────────────────────┬─────────────────────┘
                                               │ followed only when the
                                               │ controller needs the tool name
                                               ▼
  REFERENCE (per-harness, untouched)
  ┌──────────────────────────────────────────────────────────────────┐
  │ codex-tools.md → close_agent            (Codex)                   │
  │ gemini-tools.md / pi-tools.md / antigravity-tools.md → no such    │
  │ concept → nothing to do                                           │
  └──────────────────────────────────────────────────────────────────┘
```

The load-bearing consequence: **the body becomes the authority for the rule and its condition; the
reference supplies only the tool name.** `codex-tools.md`'s SDD-scoped rule sentence becomes
redundant-but-harmless rather than load-bearing — which is exactly what closes the hole for DPA and
RCR *without touching the file*.

## Design

### Architecture

There is no code. The "architecture" is the placement discipline, and it has three rules:

1. **The clause lands at the consumption point on the *unconditionally executed* path** — appended to
   the existing bullet list or paragraph that already tells the controller what to do with a returned
   result, **in that section's own form** (a bullet in a bullet list; a short paragraph in a
   paragraph section). Never a new heading, never a preamble item — and, decisively, **never in a
   section the happy path can skip** (see KDD-5: an exception handler is not the executed path).
2. **The clause lands *after* every turn-back instruction at that site.** Ordering encodes the
   condition: a controller reads "push back if the reviewer is wrong" / "send it back to the
   implementer" *first*, then reads "release it once you won't send it further input." Placement does
   half the teaching work, for free.
3. **One clause per site.** The rationale + pointer appear once per *file* (each file is read
   standalone by a controller; none imports the others), and not twice within a file.

### Key Design Decisions

#### KDD-1 — Option (c), neutral rule + in-body pointer. Not (a).

*Alternatives weighed.* **(a) Rule only**, relying on `codex-tools.md` for the mapping — the option
we publicly proposed on #1927. **(c) Rule + pointer to the per-platform refs.** ((b), naming
`close_agent` in the bodies, is ruled out by the PRD's hard neutrality constraint and is not
re-opened.)

*Why (a) fails.* The table in Current State is the whole argument. `codex-tools.md`'s rule sentence
is scoped to SDD. Under (a), the neutral "release it" we add to **DPA maps to a rule that explicitly
scopes itself to a different skill**, and the one we add to **RCR maps to nothing at all** — RCR is
not named anywhere in that file. A controller in RCR reads "release it," has no in-context path from
those words to `close_agent`, and either guesses or doesn't. Worse, a diligent DPA controller that
*does* recall the reference finds a sentence whose scoping is an argument that the obligation is
*not* its own. (a) is complete for exactly one of the three files, and our own no-touch constraint
forbids the single edit that would complete the other two. That is not a design; it is a known gap
shipped on purpose.

*Why (c) earns its keep.* One parenthetical clause per file — `(see the per-platform tool refs in
`../using-superpowers/references/`)` — moves the rule's authority into the body and demotes the
reference to a tool-name lookup, which it already is for every harness (`close_agent` is enabled for
*all* Codex multi-agent sessions by the feature flag; nothing about it is SDD-specific in fact, only
in that sentence's wording). This closes DPA and RCR **with no dependency on #1926 landing and no
follow-up PR**.

*Removability test.* Delete the pointer and you are back at (a): DPA and RCR carry an obligation with
no concrete referent. The pointer is what makes "release it" actionable on Codex. It stays.

*The load-bearing question, and the one that could have killed the pointer.* The case for (c) assumes
the controller **cannot otherwise obtain the tool name**. But our own primary source *is*
`close_agent`'s tool description — text the model is shown. **If Codex's multi-agent tools were in
context when the rule fires, the controller would already have the tool *and* a description that
already states the obligation — and the pointer would be redundant token cost, plus a hop into a file
whose SDD-scoped rule sentence might talk a DPA/RCR controller *out* of the obligation the body just
gave it. Under that condition (a) wins outright.** So we went to the source:

> `codex-rs/core/src/tools/spec_plan.rs` @ `rust-v0.142.5`, `add_collaboration_tools`, the
> **multi-agent v1** branch (L822–841):
>
> ```rust
> let exposure = if search_tool_enabled(turn_context) {
>     ToolExposure::Deferred
> } else {
>     ToolExposure::Direct
> };
> planned_tools.add_with_exposure(SpawnAgentHandler::new(/* … */), exposure);
> planned_tools.add_with_exposure(SendInputHandler, exposure);
> planned_tools.add_with_exposure(ResumeAgentHandler, exposure);
> planned_tools.add_with_exposure(WaitAgentHandler::new(/* … */), exposure);
> planned_tools.add_with_exposure(CloseAgentHandler, exposure);   // L841
> ```
>
> with `search_tool_enabled = model_info.supports_search_tool && namespace_tools_enabled`.
>
> *(Verbatim except for the two elided `…Options { … }` struct literals, marked `/* … */`. **Quote it
> this way in the PR body too** — every handler line is present, nothing is dropped. At a repo that
> closes contributions for fabricated content, a silently-trimmed "quotation" is not a shortcut worth
> taking.)*

**On any model that supports the tool-search tool, `close_agent` is `ToolExposure::Deferred` — its
name and its description are *not in the controller's context*.** The model must go find them. So on
exactly the configuration `codex-tools.md` documents (`[features] multi_agent = true` → v1), the text
that would have made the pointer redundant **is not there when the rule fires.** The pointer is
load-bearing. **(a) is refuted on the facts; (c) stands.**

*And a second finding from the same file that vindicates neutrality outright.* The **v2** branch
registers a **different tool set** — `SpawnAgent`, `SendMessage`, `FollowupTask`, `WaitAgent`,
**`InterruptAgent`**, `ListAgents` — with **no `close_agent` at all.** The release verb is not even
the same tool across multi-agent versions. Naming `close_agent` in the bodies (option (b)) would have
been **actively wrong on v2**. Only the reference layer can track which version exposes which verb; a
hard-coded body cannot. This is now the strongest argument for the PRD's neutrality constraint, and
it is independent of the cross-harness one.

*Cost.* ~10 words × 3 files. And it is strictly neutral: it names a *directory of per-platform refs*,
not a platform.

*Precedent — stated accurately, because a maintainer will check in ninety seconds.* **Do not claim
this "invents nothing."** Exactly **one** true instance of the directory-pointer construction exists
(`executing-plans` L14), and even that is a **session-start advisory to the human partner**, not a
mid-loop obligation. `writing-skills` L12 is **not** the same construction — it uses **per-file
links**, and **two of its four** (`claude-code-tools.md`, `copilot-tools.md`) point at files that do
not exist (`references/` holds `antigravity-tools.md`, `codex-tools.md`, `gemini-tools.md`,
`pi-tools.md`). So the honest claim is: **we reuse upstream's pointer *construction*, applied to a new
use.** Say that. — And `writing-skills` L12's rot is itself the best available argument *for* the
directory form we chose: **per-file links rot; a directory pointer cannot.**

*The strongest surviving argument for (a) — the repo already solves this problem class **without** a
pointer. Answered.* `codex-tools.md` carries **three** harness-conditional obligations, not one
(subagent dispatch; `## Environment Detection`; `## Codex App Finishing`), and **`## Environment
Detection` is handled with no in-body pointer at all**: `finishing-a-development-branch/SKILL.md`
carries `### Step 2: Detect Environment` as a neutral in-body step, and `codex-tools.md` points *back
at the body*. That is our clause 1 with **no clause 2** — a live precedent for (a), in the same
reference file.

**It does not transfer, and the reason is principled.** Step 2's concrete mechanism is **plain git
commands** (`git rev-parse --git-dir`, `--git-common-dir`) — **universal**, present on every harness,
in context always. There is nothing harness-specific to *reach*, so a pointer would buy nothing. Our
mechanism is the opposite on all three axes: it is **harness-specific** (only some harnesses have a
release verb), **version-specific** (v1 `close_agent` vs v2 `InterruptAgent`), and — decisively —
**deferred out of the controller's context** (the citation above). The rule generalizes cleanly:

> **Point when the concrete mechanism is harness-specific and not already in context. Don't when it is
> universal.** Environment Detection is the "don't" case; subagent release is the "do" case.

This is the durable convention the ADR should record — and it is *better* for having a counter-example
on the other side of the line.

*Rejected alternative — follow-up PR against `codex-tools.md` once #1926 lands.* This was the PRD's
other named candidate. It is worse on every axis: it makes #1927's fix **incomplete until a second PR
merges** (and #1926 may never merge); it violates one-problem-one-PR by splitting one fix across two;
and it leaves DPA/RCR controllers reading an unmapped rule in the interim. (c) needs no second PR.

*On harnesses with no ref of their own — a non-problem, stated once.* The pointer targets a
**directory**, which always resolves. A Claude Code controller follows it, finds no ref for its
harness, and correctly does nothing — which is exactly the right outcome, and what the clause's own
"on some harnesses…" rationale already told it. (`writing-skills` L12 likewise links to
`claude-code-tools.md` and `copilot-tools.md`, neither of which exists at this tip — pre-existing, and
not ours to fix.)

#### KDD-2 — The condition is stated as a clause, never as a second sentence or an exception paragraph.

The obligation and its condition are one sentence: *"release it once you have its result and don't
intend to send it further input."* An earlier draft added a following sentence spelling the exception
out ("if you're turning the same agent back for more, keep it open"). It was **cut**: it carries no
information the condition clause does not already carry, and in a repo that closes reword-and-expand
PRs, a redundant sentence is the one a reviewer points at. The condition must survive as *words
inside the step* — which is also what keeps the step a step rather than a subsection.

#### KDD-2b — **The siting rule: an intent-keyed rule must land where the intent is *determinate*, not merely where the path is guaranteed.**

This is the tiebreaker the first two revisions of this doc lacked, and its absence produced a design
that **did not fix the leak in SDD**. R1 says put the rule where it is *unconditionally executed*.
KDD-3 says key it to *intent* ("will I send this agent more input?"). **Those two criteria select
different sites, and unconditionality alone is not enough.**

Trace rev-2's SDD placement (end of `## Handling Implementer Status`). On the `DONE` path the very
next instruction is *"dispatch the task reviewer"*, and SDD's Red Flags say *"If reviewer finds
issues: Implementer (**same subagent**) fixes them."* So at the instant the rule fires and asks the
controller its question, the honest answer under the same-subagent reading is **"I don't know yet —
it depends on a review I haven't run."**

| Reading | At `Handling Implementer Status` | Later | Net |
| :--- | :--- | :--- | :--- |
| Fresh-dispatch | intent = no more input to *this* agent → **release** | — | works |
| Same-subagent | intent = *undetermined* → **hold** | reviewer returns ✅ clean; the controller is now genuinely done — **but the workflow never asks again** | **agent leaks** |

Rev 2 claimed the wording was "correct under both readings." It was correct only in the **weak**
sense that it never instructs a *wrong* action. Under the same-subagent reading it degrades to
**doing nothing** — which is the status quo, i.e. the exact leak this change exists to fix, in the
flagship skill. *"Degrades gracefully"* turned out to mean *"degrades silently into inaction."*

**The rule, stated once:** site an intent-keyed obligation at a point where the intent is **settled**
— and where the path is unconditional. In SDD, the only such point is the **task boundary** (KDD-5).
In DPA and RCR the two coincide already: RCR's step 3 is the last step (nothing follows the
push-back bullet) and DPA's step 4 ends the pattern, so at both sites the controller's intent toward
the agent is final the moment the bullet is read. **B1 bites SDD alone** — which is why only SDD's
siting changes.

#### KDD-3 — The condition must NOT be keyed to SDD's implementer statuses. This is the subtlest call in the doc.

The tempting move — and the one an executor will reach for — is to map the condition onto the four
statuses SDD already enumerates: *"DONE and DONE_WITH_CONCERNS end your use of the implementer;
NEEDS_CONTEXT and BLOCKED do not — you re-dispatch those."* It reads beautifully. **It is wrong.**

SDD's text is internally ambiguous about whether a re-dispatch reuses the same agent or spawns a
fresh one — the process digraph says *"Dispatch fix subagent"* while Red Flags says *"Implementer
(same subagent) fixes them."* PRD-002 makes resolving that ambiguity an explicit **non-goal**, and
requires our wording to be correct under **either** reading. Under the *fresh-dispatch* reading, a
`BLOCKED` implementer is an agent you are **done with** — and a status-keyed rule would tell the
controller to **hold it open forever**, manufacturing the exact leak we are fixing, in the exact
skill the issue is about.

The generic condition is correct under both readings *precisely because it says nothing about
statuses*: it asks the controller about its own intent ("will I send *this agent* more input?"), and
that question has a well-defined answer under either reading. **The wording is deliberately status-
blind. Do not "improve" it by enumerating statuses.**

#### KDD-4 — SDD gets a Red Flags entry; DPA and RCR do not.

PRD-002's acceptance for SDD explicitly requires the obligation be *"reflected where the SKILL
enumerates what a controller must never do."* SDD is the skill that accumulates agents across many
tasks — implementer + task reviewer + fixer *per task*, plus a final reviewer — and its Red Flags
list is the ledger a controller re-reads under context pressure. RCR dispatches exactly one agent and
ends; DPA dispatches one batch and ends. Their acceptance criteria in the PRD ask only for the step.
Adding a Red Flag to RCR (whose `**Never:**` list is about review discipline, not agent lifecycle) or
a "Common Mistake" to DPA (whose list is about *prompt quality*) would be unearned duplication in
tuned content — precisely the shape of edit this upstream closes. **Their Red Flags / Common Mistakes
sections are not touched.**

#### KDD-5 — SDD's rule is sited at the **task boundary**, and needs **two** instances, because that is where its four agent kinds actually finish.

Apply KDD-2b's siting rule (intent must be *determinate*) plus R1 (path must be *unconditional*), and
SDD's sites fall out. First, what "finished" means for each agent kind — **under both readings of
SDD's re-dispatch ambiguity**:

| Agent kind | Fires how often | It is finished when… | Determinate under *both* readings? |
| :--- | :--- | :--- | :--- |
| implementer | every task | **the task completes** (fresh-dispatch: at `DONE`; same-subagent: after the review loop closes) | **only at the task boundary** |
| task reviewer | every task | the task completes (it too may be re-run — *"Reviewer reviews again"*) | **only at the task boundary** |
| fix subagents | most tasks | the task completes | **only at the task boundary** |
| final whole-branch reviewer | once, after all tasks | you have acted on its findings | at the end of the final review |

**The task boundary is the unique point at which the first three are simultaneously and unambiguously
done, under either reading.** That is the whole answer to B1: it dodges the status-keying inversion
KDD-3 forbids (a `BLOCKED` agent is one you're done with — and the task still ends) *and* the
under-determination that killed rev 2 (nothing is pending; there is no review left to send anyone back
to). And SDD's own **"Fresh subagent per task"** core principle guarantees no agent survives a task
boundary, so releasing there can never orphan a reuse.

**Sites, chosen against candidates:**

- **`## Handling Reviewer ⚠️ Items` — rejected. It is an *exception handler*.** It opens *"The task
  reviewer **may** report '⚠️ Cannot verify from diff' items."* On the clean path the controller never
  reads it, so the rule would be absent from the executed path. (Rev 1 chose this. It was wrong.)
- **`## Handling Implementer Status` — rejected. Unconditional, but the intent is *undetermined*
  there.** See KDD-2b's trace: under the same-subagent reading the rule degrades to inaction and the
  agent leaks. (Rev 2 chose this. It was also wrong — and worse, it *looked* right.)
- **The Process digraph — rejected.** Its `dot` node *names are* the labels, so extending the "Mark
  task complete" node touches its declaration plus both edges — a 3-line diff to a *summary picture*,
  and it cannot carry the pointer.
- **`## Durable Progress`'s task-completion bullet — CHOSEN for the per-task agents.** It reads *"When
  a task's review comes back clean, append one line to the ledger **in the same message as your other
  bookkeeping**."* This is the **only prose step in SDD that fires at the task boundary, on every
  task**: unconditional, and the intent is settled. Releasing the task's agents *is* task-completion
  bookkeeping, and the bullet's own phrase invites it. **We accept a real cost here and name it: the
  section's heading is about surviving compaction, so the rule is off-charter for its heading.** We
  take that cost because SDD has no better task-boundary step and the constraints forbid inventing a
  new section — and because an off-heading rule that fires is worth more than an on-heading rule that
  doesn't. *This is the weakest joint in the design; it is the first thing to revisit if a maintainer
  objects.*
- **A new final bullet in `## Constructing Reviewer Prompts`, after the fix-dispatch bullet (L217) —
  CHOSEN for the final reviewer.** *Not* the L203–207 package bullet: that is
  **dispatch-preparation** — it runs **before the final reviewer is spawned** — so a release clause
  there would be a forward obligation whose own turn-back (L214–217, *"dispatch ONE fix subagent"*)
  sits seven lines **below** it, inverting Architecture rule 2. An earlier draft of this doc made
  exactly that mistake: it applied KDD-2b rigorously to the per-task agents and then forgot it here.

**The residual cost of Edit 3b, priced honestly — it does NOT meet Edit 3a's standard, and it cannot.**
Edit 3a is a *trigger* ("when a task's review comes back clean…") sited at the moment it fires. Edit 3b
is unavoidably a **forward obligation**: after the fix-dispatch bullet, SDD's next prose is `##
File Handoffs`, and `## Integration` is a skills list, not a step — **SDD has no post-final-review
prose step at any point.** There is nowhere for a "now release it" trigger to live. So the final
reviewer's rule is necessarily read *before* the moment it applies, and depends on recall across a
short span. We take that cost because:

1. There is no alternative site — the section simply does not exist.
2. The span is short and the agent is singular (one reviewer, one optional fixer, at the very end of
   the skill) — unlike the per-task agents, which fire dozens of times and where forward-obligation
   recall demonstrably fails.
3. **It is backstopped in Red Flags** (Edit 4), which is broadened specifically to name the final
   whole-branch reviewer — the one place SDD's own design says a controller re-reads under pressure.

**Do not claim Edit 3b is as strong as Edit 3a. It isn't. It is the best available, and it is fenced.**

**Two instances, not one — and this retires rev 2's "one enumeration discharges all four."** That
claim was an unevidenced assertion about controller memory, in direct tension with this change's own
founding premise (*"the reference footer is not the text the controller follows mid-loop"*). A rule
parked three steps upstream, about a *different agent*, is not meaningfully more present than a
footer. R1 means what it says: **the rule goes where it fires.** The per-task agents fire at the task
boundary (Edit 3a); the final reviewer fires at the end of the final review (Edit 3b).

#### KDD-6 — Sites deliberately NOT touched.

Each of these is a place an executor (or a reviewer) will ask about. All are out of scope:

| Site | Why not |
| :--- | :--- |
| `codex-tools.md` | PR #1926 owns it. Hard constraint. |
| SDD `## Example Workflow` | A worked transcript. Adding `[Release subagent]` lines ~6× is pure duplication of the rule and inflates the diff into "rewrote the skill" territory. |
| DPA `## Verification` | A recap of step 4, not the executed step. One landing site per file; duplicating here is the same words twice. (It survives PR #1934 — see KDD-7 — but surviving does not make it the executed path. Step 4 is.) |
| DPA `## Common Mistakes` | About *prompt quality* (too broad / no context / no constraints). A lifecycle rule does not belong in it. |
| RCR `## Red Flags` | See KDD-4. |
| **RCR `## Integration with Workflows`** | **The maintainer is deleting it in PR #1934.** Do not edit it, and do not let any added prose reference it — a cross-reference into a block obra is removing would be dead on arrival. |
| Prompt templates (`implementer-prompt.md`, `task-reviewer-prompt.md`, `code-reviewer.md`) | The **controller** releases the agent; the agent does not release itself. PRD Non-Goal. |
| `using-superpowers/SKILL.md` Platform Adaptation (omits `gemini-tools.md`, which exists) | Real, pre-existing, unrelated. Not our PR. |

#### KDD-7 — Coexistence with the maintainer's in-flight PR #1934. Verified, disjoint.

The maintainer has an **open draft PR [#1934](https://github.com/obra/superpowers/pull/1934)** —
*"refactor: strip social proof, self-selling, and recap detritus from 12 skills (eval-gated)"*, base
`dev`, held for evals — and **it touches all three of our target files.** Being surprised by a
maintainer's own draft on the exact files you are editing would be fatal at this upstream. We read
its diff. Every hunk is disjoint from ours:

| File | What #1934 does | Our insertion | Collides? |
| :--- | :--- | :--- | :--- |
| DPA | **two hunks:** L158–166 removes `**Time saved:**` + `## Key Benefits`; L174–185 removes `## Real-World Impact`. **`## Verification` and its numbered list survive between them**, as context to both. | `### 4. Review and Integrate` (L85) | **No** — ~73 lines upstream of the first hunk. |
| RCR | **two hunks:** L5–11 **rewrites** the intro paragraph (drops its tail clause — *not* a deletion of the block); L72–92 removes `## Integration with Workflows`. `## Red Flags` survives as trailing context. | step 3's bullet list (L46) | **No** — lands strictly *between* the two hunks. |
| SDD | **one hunk:** L332–369 removes the whole `## Advantages` section (L335–366). | Edit 3b `## Constructing Reviewer Prompts` (L203–207); Edit 3a `## Durable Progress` (L257–259); Edit 4 Red Flags `**Never:**` (L389) | **No** — Edits 3a/3b sit **75–130 lines upstream** of the hunk; **`## Red Flags` is the hunk's trailing *context* and is preserved verbatim**, so Edit 4 survives too. |

Two consequences the executor must honor:

1. **Anchors are the quoted text, not the line numbers.** Every line number in this doc is pinned to
   `096e15aa`. If #1934 lands first, all three files shift (SDD's Red Flags moves up ~32 lines, DPA's
   and RCR's tails shrink) but **every anchor string in Interface Design still exists, verbatim, and
   all five insertions still apply cleanly** — verified by applying #1934's three relevant file-diffs
   over the baseline (verification check 12). Re-anchor by text; never by line number. This is doubly
   necessary because **#1934 is itself stale against `dev`** (see check 12) and must be rebased before
   it lands, so its final shape may shift again.
2. **The PR body must say so — accurately.** Use exactly this, and **do not compress it into "pure
   deletions"**: that would be *false* for RCR, whose first hunk is a rewrite, and a false claim about
   the maintainer's own PR — in the one paragraph whose entire purpose is to earn credibility, at a
   repo whose signature rejection is *"slop that's made of lies"* — inverts the credit this section
   exists to buy.

   > *#1934 touches all three files: in RCR it rewrites the intro paragraph and removes `## Integration
   > with Workflows`; in DPA it removes `Time saved` / `Key Benefits` / `Real-World Impact`; in SDD it
   > removes `## Advantages`. All are disjoint from our five insertions, which land in the workflow
   > steps it preserves — this applies cleanly in either merge order.*

**And the part worth leading with.** #1934 does not merely leave our precedent intact — **it rewrites
the very sentence we are reusing, and deliberately keeps the construction.** `executing-plans` L14
today reads *"...Superpowers works much better with access to subagents. The quality of its work will
be significantly higher if run on a platform with subagent support (… see the per-platform tool refs
in `../using-superpowers/references/`)."* #1934 strips *"The quality of its work will be significantly
higher…"* as self-selling detritus and **preserves `see the per-platform tool refs in
`../using-superpowers/references/`` verbatim.** The maintainer, mid-refactor, with a scalpel out for
exactly this kind of prose, **kept the pointer clause.** That is the strongest acceptance signal this
PR has, and it belongs in the PR body.

This also **reinforces** KDD-1 and KDD-5: #1934 is deleting precisely the non-executed recap prose
(`Advantages`, `Key Benefits`, `Real-World Impact`, `Integration with Workflows`) that a lazier
version of this change might have appended to, while keeping the executed workflow steps — which is
the only place we insert. Same editorial instinct. Say so.

### Interface Design — the exact prose

Five insertions (Edits 1, 2, 3a, 3b, 4). Anchors are quoted from `096e15aa`; line numbers are at that commit. **Every added
line must be hard-wrapped to match the surrounding text's width** (~72–78 cols in SDD; the DPA/RCR
bullets are single unwrapped lines matching their lists).

> **Match by text, not by line number.** If PR #1934 lands before we do, all three files shift (see
> KDD-7). Every anchor string quoted below still exists verbatim after #1934, and all five insertions
> still apply — but the line numbers will not. Anchor on the quoted text.

---

**Bullet length is a hard constraint in RCR and DPA.** Their existing bullets run **3–7 words**
("Fix Critical issues immediately"; "Integrate all changes"). A 40-word bullet with an em-dash aside
*and* a nested parenthetical is the single highest-signal "an agent wrote this" artifact a diff can
carry — dropped into two files where the maintainer is, this month, deleting explanatory tail clauses
(#1934). So RCR and DPA **drop the "once you have its result and" anchor**: their bullets are already
positioned at the point of consumption (last under "Act on feedback"; after "Integrate all changes"),
so the phrase restates what placement already establishes. **SDD's Edit 3a keeps it** — that sentence
has no such positional anchoring, and there the phrase does real work, guarding against releasing an
agent that is still running.

`the per-platform tool refs in` is **quoted verbatim from `executing-plans` L14 and must not be
paraphrased** — the reuse is the strongest acceptance signal this PR has (see KDD-7).

---

#### Edit 1 — `skills/requesting-code-review/SKILL.md` (after L46)

Append one bullet to the existing step 3 list. **Last bullet, after the push-back bullet** — pushing
back may reuse the reviewer, so the ordering carries the condition.

```markdown
**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)
- Release the reviewer unless you intend to send it further input — on some harnesses a finished agent holds its slot until closed (see the per-platform tool refs in `../using-superpowers/references/`)

## Example
```

*(Added line is the final bullet. `## Example` shown only to fix the boundary — it is unchanged.)*

---

#### Edit 2 — `skills/dispatching-parallel-agents/SKILL.md` (after L85)

Append one bullet to `### 4. Review and Integrate`. **Last bullet, after `Integrate all changes`** —
a conflict surfaced during integration is a reason to send an agent back, so release must follow
integration, not precede it.

```markdown
### 4. Review and Integrate

When agents return:
- Read each summary
- Verify fixes don't conflict
- Run full test suite
- Integrate all changes
- Release each agent unless you intend to send it further input — on some harnesses a finished agent holds its slot until closed (see the per-platform tool refs in `../using-superpowers/references/`)

## Agent Prompt Structure
```

---

#### Edit 3a — `skills/subagent-driven-development/SKILL.md` — the **task boundary** (extends the ledger bullet in `## Durable Progress`, L257–259; section heading at L246)

Covers the **implementer, task reviewer, and fix subagents** — all three finish exactly here, under
both readings (KDD-5). **Extend the existing task-completion bullet**; do not add a new one — the
release rides along with the "other bookkeeping" the bullet already names, which is what keeps it
coherent under a heading about ledgers. Hard-wrap to the list's existing width.

```markdown
- When a task's review comes back clean, append one line to the ledger in
  the same message as your other bookkeeping:
  `Task N: complete (commits <base7>..<head7>, review clean)`.
  That bookkeeping includes releasing the subagents the task used —
  implementer, task reviewer, and any fix subagents — you will send none
  of them further input. On some harnesses a finished agent holds its slot
  until closed (see the per-platform tool refs in
  `../using-superpowers/references/`).
```

**The line break after `review clean)`.`` is load-bearing, not stylistic.** Starting the new sentence
on its own line leaves the original L257–259 **byte-identical**, so this edit is a **pure insertion of
five lines** rather than a modification. That is what makes the headline claim — *zero deletions, zero
modifications, across all five edits* — literally true in `git diff --numstat`, and it is the claim the
PR body leads with. Do not re-flow it onto L259.

The trigger is the **task boundary** (determinate under both readings); the *reason* given is intent
("you will send none of them further input"), which keeps the rule turn-back-safe, harness-neutral,
and consistent with the other two files. **Do not key it to implementer statuses** (KDD-3).

---

#### Edit 3b — `skills/subagent-driven-development/SKILL.md` — the **final whole-branch reviewer** (new final bullet in `## Constructing Reviewer Prompts`, **after** L217)

**New bullet at the end of the list** — *after* the fix-dispatch bullet (L214–217), which is the final
review's **turn-back**. This placement is not cosmetic: Architecture rule 2 requires the release
clause to follow every turn-back at its site, and the earlier draft of this edit violated it by
extending the L203–207 *dispatch-preparation* bullet — a bullet that executes **before the final
reviewer even exists**. New bullets are already the pattern here (Edits 1, 2, 4), and R6 forbids only
new *headings* and new *numbered steps*. No rationale or pointer: Edit 3a carries both, in the same
document.

```markdown
- If the final whole-branch review returns findings, dispatch ONE fix
  subagent with the complete findings list — not one fixer per finding.
  Per-finding fixers each rebuild context and re-run suites; a real
  session's final-review fix wave cost more than all its tasks combined.
- Release the final whole-branch reviewer, and any fixer it triggered, once
  you have acted on its findings and will send them no further input.

## File Handoffs
```

*(Only the last bullet is added; the fix-dispatch bullet and `## File Handoffs` are shown to fix the
boundary and are unchanged.)*

---

#### Edit 4 — `skills/subagent-driven-development/SKILL.md` (after L389)

Append one bullet to the Red Flags `**Never:**` list, as its **final** entry. Matches the list's
style (hard-wrapped, em-dash clarifier). Deliberately omits the rationale and pointer — Edit 3a
carries both, in the same document.

**It must cover *both* agent populations.** A task-scoped Red Flag would by construction **exclude the
final whole-branch reviewer** — leaving the one agent whose rule is *necessarily* a forward obligation
(Edit 3b; see KDD-5) with **no backstop at all**, in the one section SDD's own design says a
controller re-reads under context pressure. That is where this coverage gap actually closes.

```markdown
- Move to next task while the review has open Critical/Important issues
- Re-dispatch a task the progress ledger already marks complete — check
  the ledger (and `git log`) after any compaction or resume
- Leave subagents open once you are finished with them — release a task's
  implementer, reviewer and fixers at task close-out, and the final
  whole-branch reviewer once you have acted on its findings; you will send
  none of them further input

**If subagent asks questions:**
```

*(Only the four-line `**Never:**` bullet is added. `**If subagent asks questions:**` is unchanged — and note it is
followed later by `**If reviewer finds issues:** - Implementer (same subagent) fixes them`, which is
**not touched** and is exactly why KDD-3's status-blind wording is mandatory.)*

---

**Diff budget:** **five insertions, 13 added lines (RCR +1, DPA +1, SDD +11), 0 lines deleted, 0 lines modified** (163 words; the LINE counts are the checkable claim — `git diff --numstat` must read exactly `1 0`, `1 0`, `11 0`. Do NOT put a word count in the PR body: it is unverifiable and was wrong here for three revisions.) Edits 1, 2,
3b and 4 are new bullets; Edit 3a adds whole new lines *inside* an existing bullet without touching any
of its existing lines (see its note). **Every hunk is a pure insertion** — `git diff --numstat` shows a
deletion count of zero on all three files. No existing sentence is altered, shortened, or reworded. The
diff reads as "someone added a clause," never "someone rewrote a skill" — which is the whole game at
this upstream, and the claim the PR body leads with.

## Implementation Phases

### Phase 1 (only): Land the five insertions

One phase. This is a 13-line prose addition to three files with no build step, no runtime surface,
and no sequencing between the edits. Splitting it into phases would be manufactured ceremony — the
"unearned mechanism" the design principles forbid — and would also violate one-problem-one-PR
upstream.

**Goal.** A controller reading any of the three workflows in order reaches an explicit, conditioned
release step at the point it consumes a subagent's result.

**Deliverables.** Edits 1, 2, 3a, 3b and 4 exactly as specified in Interface Design, on a branch cut from
`upstream/dev`, targeting `dev`.

**Test strategy (written first — see Verification).** There is no test to write: no harness in this
repo asserts on skill prose, and the target behavior is only observable inside a live Codex
multi-agent session we cannot drive. The check-first artifact is therefore the **verification script
in the next section**, which is written and run *before* the PR is opened; its assertions are the
binary gates. This is stated as a limitation, not dressed up as TDD.

**Infrastructure.** None. Zero dependencies, zero files added.

**Documentation.** The three `SKILL.md` files *are* the documentation. No other doc changes — in
particular, `codex-tools.md` is not touched.

**Dependencies.** None. Explicitly **not** blocked on PR #1926 (that is the point of KDD-1). Re-check
`codex-tools.md`'s state at `dev` tip immediately before opening the PR, per PRD risk.

**Definition of done (binary).**
- [ ] All **five** insertions present, verbatim as specified (Edits 1, 2, 3a, 3b, 4).
- [ ] SDD's rule is at the **task boundary** (`## Durable Progress`'s task-completion bullet), **not**
      in `## Handling Implementer Status` or `## Handling Reviewer ⚠️ Items` (KDD-2b/KDD-5).
- [ ] The final whole-branch reviewer has its own instance (Edit 3b), as a **new final bullet** in
      `## Constructing Reviewer Prompts`, **after** the fix-dispatch turn-back (L214–217) — **not** on
      the L203–207 package bullet, which executes *before the reviewer is dispatched* (KDD-2b/B4).
- [ ] `git diff --stat` vs `upstream/dev`: exactly 3 files, all `SKILL.md`.
- [ ] `git diff --numstat`: **0 deletions on all three files** — every hunk is a pure insertion.
- [ ] No added line matches `close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b`.
- [ ] No added line is a heading (`^\+#`) or a new numbered step (`^\+\*\*[0-9]+\.`).
- [ ] `skills/using-superpowers/` has zero changes.
- [ ] All five release instances state the intent condition in the same sentence (R2). Verification
      check 6 is the gate: `grep -c 'further input'` must be 3 (SDD) / 1 (DPA) / 1 (RCR). Do NOT gate on
      a fixed phrase — three of the five legitimately use "send none of them/them no further input".
- [ ] `../using-superpowers/references/` resolves from all three skill dirs.
- [ ] No added line sits in, or references, a section PR #1934 deletes (`Advantages`, `Key Benefits`,
      `Real-World Impact`, `Integration with Workflows`, `Time saved`) — verification check 11.
- [ ] The five insertions still apply over #1934's head — verification check 12.
- [ ] `tests/claude-code/test-subagent-driven-development.sh` passes.
- [ ] The PR body carries the one-sentence #1934 disjointness statement (KDD-7 §2).
- [ ] A human has read the complete diff (upstream requirement).

## Verification

Mechanical, and honest about its ceiling.

### What we can prove (structural — run all of these)

Run from repo root, with the branch checked out:

```bash
BASE=096e15aa736d2e920fb7f1e2c954604f02ebbdb0

# 1. Diff shape: exactly three files, all SKILL.md  [R6]
git diff --stat "$BASE"...HEAD
git diff --name-only "$BASE"...HEAD | grep -cv 'SKILL\.md$'          # must print 0
git diff --name-only "$BASE"...HEAD | wc -l                          # must print 3

# 2. The no-touch constraint on #1926's file  [R6]
git diff --name-only "$BASE"...HEAD -- skills/using-superpowers/     # must print nothing

# 3. Pure addition: no tuned content deleted  [R6]
git diff --numstat "$BASE"...HEAD    # deletions column must be 0 / 0 / 0. All five edits are pure
                                    # insertions: Edit 3a adds whole lines INSIDE an existing bullet
                                    # (L257-259 stay byte-identical); 3b and 4 are new bullets; 1 and
                                    # 2 are new bullets. A nonzero deletion count means someone
                                    # re-flowed an existing line — fix the wrap, don't accept it.

# 4. Harness neutrality — no tool or platform name on any ADDED line  [R5]
git diff "$BASE"...HEAD | grep -E '^\+' \
  | grep -nE 'close_agent|spawn_agent|wait_agent|send_input|Codex|Claude|OpenCode|Gemini|Copilot|\bPi\b'
                                                                     # must find nothing

# 5. No new sections, no new numbered steps  [R6]
git diff "$BASE"...HEAD | grep -E '^\+#{1,6} |^\+\*\*[0-9]+\.'       # must find nothing

# 6. The rule, with its condition, at every fire point  [R1 R2 R3]
grep -c 'further input' \
  skills/subagent-driven-development/SKILL.md \
  skills/dispatching-parallel-agents/SKILL.md \
  skills/requesting-code-review/SKILL.md       # must be 3 / 1 / 1
#   SDD's 3 = Edit 3a (task boundary) + Edit 3b (final reviewer) + Edit 4 (Red Flags).
#   A count of 2 in SDD means an agent kind lost its fire-point instance — R1 has regressed.

# 7. The pointer, in all three bodies  [R4]
grep -c 'using-superpowers/references/' \
  skills/subagent-driven-development/SKILL.md \
  skills/dispatching-parallel-agents/SKILL.md \
  skills/requesting-code-review/SKILL.md       # must be >=1 each

# 8. The pointer actually resolves from each skill dir  [R4]
for s in subagent-driven-development dispatching-parallel-agents requesting-code-review; do
  (cd "skills/$s" && test -d ../using-superpowers/references) \
    && echo "OK  $s" || echo "BROKEN  $s"
done

# 9. The release step follows every turn-back at its site  [Architecture rule 2]
awk '/^\*\*3\. Act on feedback/,/^## Example/' skills/requesting-code-review/SKILL.md
awk '/^### 4\. Review and Integrate/,/^## Agent Prompt/' skills/dispatching-parallel-agents/SKILL.md
#   read both: the release bullet must be LAST.

# 10. KDD-3 guard — the SDD rule must be status-blind
git diff "$BASE"...HEAD | grep -E '^\+' | grep -E 'NEEDS_CONTEXT|BLOCKED|DONE_WITH_CONCERNS'
                                                                     # must find nothing

# 11. KDD-7 guard — nothing we add may live in, or reference, a section PR #1934 deletes
git diff "$BASE"...HEAD | grep -E '^\+' \
  | grep -E 'Advantages|Key Benefits|Real-World Impact|Integration with Workflows|Time saved'
                                                                     # must find nothing

# 12. KDD-7 rebase drill — #1934 must still apply over OUR three files, at the pinned baseline.
#     TWO TRAPS, both hit in practice:
#     (a) `git apply --check` validates against the WORKING TREE, not $BASE. On a fork whose main
#         predates $BASE it can silently PASS against the wrong text. Run it in a worktree at $BASE.
#     (b) The FULL #1934 diff does NOT apply at $BASE — it fails on skills/executing-plans/SKILL.md,
#         a file we never touch: #1934 (2026-07-05) predates $BASE ("Revert 'Remove Gemini CLI
#         support'"), so its base for L14 lacks "and Gemini CLI". That is #1934 being stale against
#         `dev`, not a conflict with us. SCOPE THE CHECK TO OUR THREE FILES.
gh pr diff 1934 --repo obra/superpowers > /tmp/1934.diff
git worktree add /tmp/base "$BASE"
git -C /tmp/base apply --check \
  --include='skills/subagent-driven-development/*' \
  --include='skills/dispatching-parallel-agents/*' \
  --include='skills/requesting-code-review/*' /tmp/1934.diff        # must be CLEAN (verified)
git worktree remove /tmp/base
```

Checks 10–12 each earn their line. Check 10 is the one way an executor's "helpful improvement"
silently reintroduces the bug KDD-3 exists to prevent. Check 11 is the one way our prose ends up in
text the maintainer is already deleting. Check 12, run naively, gives a **false pass** on this fork
and a **false alarm** at the baseline — both traps are spelled out above because both were hit.

### Regression check (behavioral, on the one harness we have)

```bash
tests/claude-code/test-subagent-driven-development.sh     # requires the `claude` CLI
```

This drives a real Claude Code session and string-matches SDD's description against expected
keywords. Our change **deletes nothing**, so every existing assertion must still pass; a failure would
mean we disturbed tuned content. `tests/claude-code/test-subagent-driven-development-integration.sh`
(a real plan execution, ~10 min + API spend) is the stronger no-harm check and should be run once
before the PR: it proves the new clause does not derail SDD on a harness with **no** release concept —
which is PRD feature 5's acceptance, and the only behavioral evidence available to us.

### What we cannot prove — state this plainly, in the PR body

**No live Codex multi-agent session was run. We cannot drive one.** We have not observed a
concurrency slot being held, nor one being released. Neither has anyone on issue #1927 — the reporter
observed the tool surface, not an exhausted pool. Consequently:

- The Codex mechanism is **cited, not observed**: `multi_agents_spec.rs` L296 @ `rust-v0.142.5`
  ("Completed agents remain open and count toward the concurrency limit until closed") and L143
  (`send_input` reuse).
- The superpowers-side gap is **grep-verified** on Linux at `dev` tip `096e15aa`.
- The change itself is verified **structurally, not behaviorally**: we prove the release step exists,
  sits in the executed path, is reuse-safe by construction, names no harness tool, and resolves to a
  real reference directory. We do **not** prove a Codex controller then calls `close_agent`.

That last sentence is the honest ceiling of this PR and must not be softened in the PR body.

**And do not claim the downside is merely "inert, not harmful" — that is too comfortable, and our own
analysis contradicts it.** The realistic worst case has teeth: a DPA or RCR controller follows the
pointer, lands in `codex-tools.md`, and reads a rule sentence **scoped to `subagent-driven-development`
alone** — from which it may conclude it is *exempt*. That is the pointer **subtracting** compliance
relative to no pointer at all. The honest formulation:

- The rule does **not** depend on the reference layer being **complete** — a harness with no ref file
  is a correct no-op (that *is* the answer for such a harness).
- It **does** depend on the reference layer not being **actively misleading** — and on Codex today,
  for two of our three skills, **it is** (the SDD-scoped rule sentence). We are shipping the body-side
  rule *because* the reference is wrong, and we cannot fix the reference (#1926 owns it).
- The clean resolution is the follow-up this design already anticipates: once #1926 lands, widen that
  sentence — or delete it, since the bodies now carry the rule. **Say this in the PR**; it converts a
  hidden weakness into a stated, scheduled one.

## Migration & Rollback

**Migration: N/A — pure prose addition.** No state, no schema, no config, no consumer contract.

**Rollback:** revert the commit. Nothing depends on the added text; no other file references it.

**Forward-compat with PR #1926:** we touch no file it owns, so it cannot conflict. If #1926 later
widens `codex-tools.md`'s rule sentence beyond SDD, our pointer still resolves and our bodies still
carry the rule — the two changes compose rather than collide. Re-read `codex-tools.md` at `dev` tip
immediately before opening the PR anyway (cheap, and PRD-listed).

**Forward-compat with PR #1934 (the maintainer's own draft, same three files):** verified disjoint —
see KDD-7. Its hunks in our three files remove `Advantages` / `Key Benefits` / `Real-World Impact` /
`Integration with Workflows` **and rewrite RCR's intro paragraph**; we insert only into the executed
workflow steps it preserves. (Do NOT compress this to "#1934 only deletes" — that is false, and the
falsehood is about the maintainer's own PR. See the risk rows below.)
The change applies cleanly in **either** merge order, and needs no rebase beyond re-anchoring on text.
Re-run verification checks 11–12 immediately before opening the PR, in case #1934 is updated (it has
not been touched since 2026-07-05).

**Correction owed to #1927.** Our intent comment on the issue proposed the harness-agnostic direction
*without* the pointer (option (a)). We are landing (c). Post a short follow-up on the thread before or
with the PR, stating the change and the reason in one line: `codex-tools.md`'s rule sentence is scoped
to `subagent-driven-development` alone, so a rule added to `dispatching-parallel-agents` and
`requesting-code-review` needs the in-body pointer to reach a concrete tool — and PR #1926 owns the
file that would otherwise be widened. This is not optional; leaving a superseded proposal standing on
a maintainer's thread is exactly the sloppiness this upstream punishes.

## Risks

| Risk | Impact | Likelihood | Mitigation |
| :--- | :--- | :--- | :--- |
| Maintainer reads this as **behavior-tuning of skill content** and demands eval evidence we cannot supply. | High — closes the PR. | Medium | Frame as **platform tool-mapping correctness**: the rule already exists in-repo and is already mandatory; we are moving it into the executed path. Lead with the pinned `multi_agents_spec.rs` quote and the grep. Keep the diff at five small hunks. Note the pointer reuses `executing-plans` L14's existing construction (a new *use* of it — do not overclaim), and that `close_agent` is `ToolExposure::Deferred` so the rule cannot reach the tool without it. |
| Executor "improves" the SDD wording by keying the condition to implementer statuses. | High — silently reintroduces the leak on the fresh-dispatch reading, in the flagship skill. | **Medium — it is the natural edit** | KDD-3 spells out why it is wrong; verification check 10 greps for `NEEDS_CONTEXT\|BLOCKED\|DONE_WITH_CONCERNS` on added lines and fails the build. |
| A neutral "release it" **still fails to trigger `close_agent`** on Codex. | Medium — the change is inert. | Medium | This is PRD-002's one stated assumption and the reason the pointer exists: (c) is strictly better than (a) here, because the controller has a path from the words to the tool *at the moment it matters*. We cannot eval it; we say so. |
| Three files reads as **scope creep** (issue names two firmly). | Medium | Low | The strong argument is not that #1927 mentions RCR — it is that **SDD's final whole-branch review dispatches through RCR's `code-reviewer.md` template** (SDD's own digraph and Prompt Templates say so), so RCR is on SDD's critical path and leaks on every SDD run. Lead with that in the PR; the issue's mention is corroboration, not the case. |
| **RCR/DPA bullets read as agent-written** (5–10× their siblings' length) in the two files obra is currently de-wordifying. | Medium — it is the tell a maintainer pattern-matches on. | Medium | S2 tightening: drop the "once you have its result and" anchor in RCR/DPA (placement already establishes it), "until closed", no redundant clause. ~27 words, one aside. Keep `the per-platform tool refs in` verbatim — that phrase is the asset, not the bloat. |
| **Executor re-sites SDD's rule to a "more natural" section** — `## Handling Reviewer ⚠️ Items` (rev 1) or `## Handling Implementer Status` (rev 2). Both read better than `## Durable Progress`. | **High — and it silently un-fixes the bug.** The ⚠️ section is an *exception handler* the clean path never enters. `Handling Implementer Status` is unconditional but the controller's **intent is undetermined there** (the task review hasn't run), so under the same-subagent reading the rule degrades to inaction and the agent leaks anyway. | **Medium — both are tempting, and both were shipped in earlier revisions of this doc** | KDD-2b + KDD-5. The anchor is the **task boundary** (`## Durable Progress`'s task-completion bullet) — the only prose step in SDD that is *both* unconditional *and* intent-determinate. Verification check 6 fails if SDD's count drops from 3. |
| **`## Durable Progress` is off-charter for the rule** (its heading is about surviving compaction). A maintainer may object to a lifecycle rule living there. | Medium — a review comment, not a leak. | Medium | Acknowledged in KDD-5 as **the weakest joint in the design**, and taken deliberately: SDD has no other task-boundary step, and the constraints forbid inventing a new section. The bullet's own phrase — *"in the same message as your other bookkeeping"* — is what makes it coherent. If the maintainer pushes back, this is the first thing to move. |
| **The maintainer's own open draft PR [#1934](https://github.com/obra/superpowers/pull/1934) touches all three of our files.** Being blindsided by it — or landing prose into text he is deleting — would read as not having looked. | **High** — a maintainer who sees us edit around his in-flight refactor without acknowledging it closes the PR. | Low **now that we have checked it** | KDD-7: we read its diff, hunk by hunk. **All five of our insertions are disjoint from every hunk and land in the workflow steps #1934 preserves.** Verification checks 11–12 enforce it. The PR body states it per-file and **must not compress it to "pure deletions"** — RCR's first hunk is a *rewrite*, and a false claim about the maintainer's own PR would invert the credit this buys. |
| **Describing #1934 inaccurately in the PR body** (e.g. "pure deletions") to make the disjointness sentence shorter. | **High** — at a repo whose signature rejection is *"slop that's made of lies"*, an easily-checked false claim about the maintainer's own open PR is fatal, and it lands in the one paragraph meant to earn trust. | Medium — the compression is tempting | KDD-7 §2 supplies the exact, verified sentence. Use it verbatim. |
| #1934 lands first and our patch no longer applies by line number. | Low | Medium | Anchors are quoted text, not line numbers (KDD-7 §1). Every anchor string survives #1934 verbatim. Re-anchor and re-run checks 1–11. |

## Roadmap Connection

`m1/s1/codex-integration/codex-subagent-lifecycle` — this design serves PRD-002 and upstream issue
#1927. Sibling `codex-deferred-tools-docs` (PR #1926) owns `codex-tools.md`; **this design is
deliberately decoupled from it** and does not wait on it (KDD-1).

Next: PRD-002 also calls for an **ADR** recording the durable convention this instance establishes —
*how a harness-specific tool lifecycle is expressed in a cross-harness skill body*: state the
obligation and its condition neutrally in the body at the point of use, and point at
`using-superpowers/references/` for the mapping; never name the tool in the body. That is the reusable
rule, and it is what KDD-1 decides. The ADR distills it; it is not re-argued there.

## Open Questions

1. **Maintainer sanity-check on #1927 is still pending.** If a maintainer replies before the PR
   opens, that reply outranks KDD-1. If it explicitly blesses pure (a), drop the three pointer
   parentheticals and ship the rule alone — but say in the PR that DPA and RCR then have no concrete
   mapping until `codex-tools.md` is widened.
2. **Assumed appetite (autonomous sizing decision, recorded per the design-doc process).** We assumed
   the appetite is *"the smallest addition that puts the rule at every point where it actually fires,
   and nothing else"* — i.e. five insertions, 13 added lines, no new sections, no touched Example
   Workflow, no touched prompt templates. Grounds: the PRD's Constraints (~94% rejection; reword PRs
   closed on sight) and its explicit "the diff is confined to the three workflow bodies and stays
   minimal." **This is the assumption to challenge if the doc later reads as under-built.** Note the
   sizing pressure now cuts *both* ways: rev 2 shaved to four insertions and, in doing so, **shipped a
   design that did not fix the bug** (KDD-2b). Minimalism is a constraint, not a goal — the rule must
   land where it fires, and R1 is not negotiable to save a line.
3. ~~*Is one instance enough in SDD?*~~ **Closed — and the answer was NO.** Rev 2 asserted one
   instance sufficed via an inline enumeration. That was an unevidenced claim about controller recall,
   in direct tension with this change's own founding premise. SDD now carries **two** rule instances
   (Edit 3a at the task boundary; Edit 3b for the final whole-branch reviewer) plus the Red Flags
   backstop. **Do not consolidate them back into one.**

---
## Revision History
| Date | Author | Notes |
| :--- | :--- | :--- |
| 2026-07-13 | cameron | Initial draft. Resolves PRD-002's routed open decision in favour of **option (c)** (neutral rule + in-body pointer), on the strength of two findings: `codex-tools.md`'s rule sentence is SDD-scoped so (a) leaves DPA and RCR unmapped, and `executing-plans` L14 already establishes the in-body pointer idiom verbatim, so (c) invents nothing. Specifies all four insertions as final prose. Flags the correction owed to issue #1927. |
| 2026-07-13 | cameron | Added **KDD-7** after reading the maintainer's open draft PR #1934, which touches all three target files. Verified its hunks are disjoint from all four insertions. Anchors re-stated as text-not-line-number. |
| 2026-07-13 | cameron | **Rev 4 — KDD-2b applied to the one edit that had escaped it.** **(B4)** Rev 3's Edit 3b extended SDD's L203–207 bullet, which is **dispatch *preparation*** — it runs **before the final reviewer is spawned** — making the release a forward obligation whose own turn-back (L214–217, *"dispatch ONE fix subagent"*) sits **seven lines below it**, inverting Architecture rule 2. Rev 3 applied the determinacy tiebreaker rigorously to the per-task agents and then failed to apply it to the final reviewer. **Re-sited Edit 3b as a new final bullet in `## Constructing Reviewer Prompts`, after L217** (new bullets are already the pattern; R6 forbids only new headings/numbered steps). **Priced the residual honestly instead of hiding it:** SDD has **no post-final-review prose step at all** (after L217 comes `## File Handoffs`; `## Integration` is a skills list), so the final reviewer's rule is *necessarily* a forward obligation — **Edit 3b does not meet Edit 3a's standard and cannot**; it is fenced by short span, a singular agent, and a backstop. **Broadened Edit 4** accordingly: a task-scoped Red Flag would by construction have **excluded the final whole-branch reviewer**, leaving the one forward-obligation agent with no coverage in the ledger controllers re-read under pressure. **Gate defects fixed** — the DoD would have **failed a correct diff**: it mandated the literal substring `send it further input`, which **three of five** instances legitimately do not use; restated **R2** to require the *intent condition*, not a fixed phrase, and pointed the gate at check 6 (`further input`, 3/1/1). Tightened Edit 3a by ~10 words. Marked the elision in the Rust quotation rather than trimming it silently. Stale counts (four→five) swept. |
| 2026-07-13 | cameron | **Rev 3, after the ADR reviewer found a hole in the *design* — the change as specified in rev 2 did not fix the leak in SDD.** **(B1)** Rev 2 sited SDD's rule at the end of `## Handling Implementer Status`: unconditional, but the controller's **intent is undetermined there** (the task review has not run, and SDD's Red Flags say the *same subagent* may fix findings). Under the same-subagent reading the rule degraded to **inaction** — the status quo, i.e. the leak, in the flagship skill. Added **KDD-2b**, the missing tiebreaker: *an intent-keyed rule must be sited where the intent is **determinate**, not merely where the path is unconditional.* Re-sited SDD to the **task boundary** (`## Durable Progress`'s task-completion bullet — the only prose step that is both unconditional and intent-settled), where all three per-task agent kinds finish under **both** readings; **added a second SDD instance** (Edit 3b) for the final whole-branch reviewer on the *unconditional* final-review bullet, retiring rev 2's unevidenced "one enumeration discharges all four" (which relied on exactly the mid-loop recall this change's own premise denies). **(B3)** Went to `codex-rs` and **refuted the strongest case for option (a)**: `close_agent` is registered **`ToolExposure::Deferred`** (`spec_plan.rs` L822–841 @ `rust-v0.142.5`), so its obligation-bearing description is **not in context** when the rule fires — the pointer is load-bearing, and **(c) stands on evidence rather than assertion**. Same file yielded a bonus: multi-agent **v2 exposes no `close_agent` at all** (`InterruptAgent` instead), so the release verb is not stable across versions — an independent vindication of neutrality. **(S4)** Answered the live counter-precedent (`finishing-a-development-branch`'s `Step 2: Detect Environment` solves this class with **no** pointer): it doesn't transfer, because *its* mechanism is plain git — universal and in-context. Yields the durable rule: **point when the mechanism is harness-specific and not in context; don't when it is universal.** **(S2)** Corrected the precedent claim — only `executing-plans:14` is a true instance, and it is a session-start advisory, so we reuse the *construction* for a *new use*; **do not say "invents nothing."** (`writing-skills:12` uses per-file links, **2 of 4** dead — which is itself the argument for the directory form.) **(S1/S3)** Killed the too-comfortable "inert, not harmful": the pointer can **subtract** compliance where the reference is actively misleading, which on Codex it is. |
| 2026-07-13 | cameron | **Rev 2, after adversarial design review (REVISE; central decision (c)/KDD-1/KDD-3 upheld unchanged).** Two blocking fixes: **(B1)** moved SDD's rule from `## Handling Reviewer ⚠️ Items` — an **exception handler** the happy path never enters, which would have left SDD's executed path with no release instruction and silently failed R1 — to `## Handling Implementer Status`, which every task enters exactly once; KDD-5 rewritten around *unconditionality*, not heading fit; retires Open Question 3. **(B2)** the mandated PR-body sentence claimed #1934's hunks were "pure deletions" — **false for RCR, whose first hunk is a rewrite**; corrected to an accurate per-file sentence (telling obra a false thing about obra's own PR, in the paragraph meant to buy credibility, at a repo whose signature rejection is "slop that's made of lies"). Plus: surfaced the **gift** — #1934 rewrites `executing-plans` L14 and *keeps our pointer construction verbatim*, the best acceptance signal we have; grounded RCR's leak in **SDD's own digraph** (its final review dispatches through RCR's template) rather than inferring it; tightened RCR/DPA bullets from ~40 to ~27 words (siblings run 3–7) while keeping the `send it further input` substring R2/check-6 depend on; fixed verification check 12, which gave a **false pass** on this fork (`git apply --check` validates the working tree, not `$BASE`) and a **false alarm** at the baseline (#1934 is stale against `dev` and fails on `executing-plans`, a file we never touch); all four hunks are now **pure insertions, 0 lines modified**. |
