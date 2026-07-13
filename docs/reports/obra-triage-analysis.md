# The obra/superpowers AI-Triage Corpus: What Actually Gets a PR Closed

**Analyst:** hand-coded, 42/42 items read in full.
**Corpus date range:** 2026-07-09 (37 closures) and 2026-07-10 (5 closures).
**Report date:** 2026-07-13.

---

## 1. Scope, method, and what this corrects

### The corpus

All 42 closures from obra's AI-assisted triage sweep of `obra/superpowers`. They are identifiable
by a preamble the agent posts under Jesse's account:

> "Hi @tianma-if — I'm Claude, an AI agent (Fable 5, running in Claude Code), posting from Jesse
> (@obra)'s account at his direction. Jesse had me run a skeptical triage of all 340 open
> superpowers items — every factual claim tested against the current `dev` tree, then adversarially
> re-checked by a second, independent agent — and he reviewed the verdicts and directed these
> closures." — **#1904**

This preamble was stripped from the captured bodies for 39 of 42; it survives inline in **#1904,
#1937, #1950** (the agent varied the wording there, so the strip missed it). Those three are the
proof the preamble exists and the proof of what the process was: *every factual claim tested against
`dev`, then adversarially re-checked by a second independent agent.*

**This is the live rubric.** The repo has ~714 lifetime closures; the other ~672 predate this sweep
and were closed under a different (human, ad-hoc) process. Extrapolating from them is a mistake.

### Composition (verified via `gh`, not inferred from text)

| | count |
|---|---|
| Pull requests | **28** |
| Issues | **14** |
| Total | **42** |

The corpus is routinely described as "PR closures." It is not. A third of it is issues. Several of
the most-cited "rules" (venue calls, not-our-bug calls) are disproportionately *issue* closures and
say nothing about how PRs die.

### Method

For each of the 42 I read the closing comment end to end and recorded, by hand: primary reason
(the thing obra leads with and returns to), secondary reasons, whether obra explicitly conceded the
bug was real or the code correct, and whether a retry invitation was offered. Metadata (author,
+/-, files, base branch, head branch) came from `gh pr view <n> -R obra/superpowers --json
author,additions,deletions,changedFiles,baseRefName,headRefName` and `gh issue view` for the 14
issues. Counts in §4 and §5 are hand-assigned category counts with every backing number listed.
Three counts are mechanical string checks over the corpus (footer presence, inline-preamble
presence, base branch) and are labelled as such.

### What I did NOT verify

- I did not read the PRs' own bodies or diffs. Every claim about what a submission said or did
  ("the template was blank", "the diff is byte-identical to #1159") is **obra's assertion**, taken
  at face value. I verified only the metadata `gh` returns.
- I did not check whether the retry invitations were taken up, or whether any closure was reversed.
- I did not verify obra's git archaeology (that commit `e7ddc25` removed X, that `3f725ff` added Y).
- Author identity: I have GitHub logins. I did not verify obra's claims that `msh01` does not exist
  or that `@Bortlesboat` is a scripted account. (These are trivially checkable and were checked by
  the triage agent; I flag them as unverified *by me*.)

### Priors this corrects

| Prior claim | Truth |
|---|---|
| "28 closures in the AI-triage corpus" | **42.** (28 happens to be the number of *PRs*; the 14 issues were dropped.) |
| "batch: 35" (regex tag count) | **3 distinct batch incidents**, touching **10 of the 42** closures. The regex was counting the *word*, not the *event* — obra names the batch in every sibling closure, so one 10-PR incident produces ten mentions. See §5. |

Regex-counting this corpus does not work. Obra's closures are long, cite five to eight prior
issues each, and routinely mention a policy in order to say *it is not the reason for the closure*
(#956: "this targets `main` and we land on `dev`, but that's just housekeeping, not why we're
closing"). Keyword presence is anti-correlated with causality here.

---

## 2. The closure template — six moves

Every closure in the corpus makes some subset of these six moves, in this order. This structure is
the rubric; each move is a check the triage agent ran and is telling you it ran.

**Move 1 — Disclosure of the triage process** (all 42; visible inline in #1904, #1937, #1950).

**Move 2 — Concede what is true, specifically and first.** Not politeness. It is the agent proving
it actually ran the thing before disqualifying it.

> "To be clear up front: the underlying bug is real. A linked worktree's `.git` is a file, so the
> `[[ -d "$REPO_ROOT/.git" ]]` check does reject a valid checkout... The problem isn't the code."
> — **#1910**

> "Thanks for finding a real bug: `tests/antigravity/test-antigravity-tools.sh` does currently fail
> on dev with exactly the error you quoted, and I confirmed this diff fixes it cleanly in an
> isolated clone" — **#1902**

**Move 3 — The disqualifier, tied to a named policy line in CLAUDE.md.**

> "that is the spray-and-pray pattern our CLAUDE.md says gets closed regardless of individual merit"
> — **#1901**

> "this falls under CLAUDE.md's zero-dependency policy: the skill's core function is querying an
> external registry (npm/PyPI/crates.io) at runtime, which is exactly 'a change that requires an
> external tool or service' per the 'What We Will Not Accept' section." — **#937**

**Move 4 — Prior art, by number.** 38 of 42 closures cite at least one prior PR, issue, or commit
SHA by identifier. The four that cite none: **#1533, #1569, #1671, #1950**. This is the move that
makes the closure unarguable — it shows the decision was already made, often years of thread ago.

> "it's the same reasoning we used in May to close #1005, a narrower version of this same request"
> — **#730**

**Move 5 — Secondary faults, explicitly ranked as secondary.** Housekeeping is listed *and*
explicitly denied causal weight. This is the tell people misread.

> "Also minor: this targets `main` and we land on `dev`, but that's just housekeeping, not why we're
> closing." — **#956**

> "The link fix itself is correct — evals/ is gitignored and the replacement URL resolves — so this
> is being closed for the batch pattern, not the diff." — **#1907**

**Move 6 — A retry invitation with a concrete spec, or the revisitable footer, or both.**

The footer — *"If you think this call is wrong, reply here — Jesse reads these, and closures can be
revisited."* — appears on exactly **16 of 42** (string-checked): #597, #683, #730, #937, #968,
#1007, #1099, #1143, #1243, #1569, #1574, #1671, #1817, #1913, #1940, #1944.

**Every one of those 16 is a venue call or a not-our-defect call. Zero closures alleging batching,
fabrication, false statements, reverted tuning, or non-reproduction carry it.** The footer is the
soft-track marker. (Two soft-track closures lack it: #956 and #1950.)

---

## 3. THE MASTER TABLE — all 42

Sizes are `+additions/-deletions`, `Nf` = files changed. `—` = issue (no diff). "Code correct?" =
did obra explicitly concede the bug was real or the diff correct.

| # | type | author | size | base | primary reason (mine) | code correct? | retry offered? |
|---|---|---|---|---|---|---|---|
| 597 | issue | nikolaspadilla | — | — | Superseded — closed in favor of #1836; isolation scheme too stack-specific to generalize into core | **yes** — "I confirmed `using-git-worktrees` has no port or database isolation logic today" | no (redirects to project CLAUDE.md) |
| 627 | PR | stablegenius49 | +20/-1, 1f | main | Batch (1 of 12 `pr-factory/issue-NNN-*` PRs in ~6h) | **yes** — "The underlying gap in #593 is real" | **yes** |
| 634 | PR | stablegenius49 | +15/-0, 1f | main | Batch; and patches a README section deleted in April — a real test-merge lands the text disconnected from anything | no — content is stale against `main` | **yes** |
| 640 | PR | stablegenius49 | +4/-2, 1f | main | Batch; 342 commits stale, genuine conflict; hardens a guardrail the maintainer leaned toward *relaxing* | no | no (points to #1213) |
| 683 | PR | LakshmiSravyaVedantham | +476/-0, 4f | main | Venue — PM-orchestrates-subagents system; shape declined before (#61, #449/#470/#492/#733/#1003/#1276) | partial — "coherent and clearly thought through", but hardcodes a nonexistent `5.0.0` cache path | **yes** (as own plugin) |
| 730 | issue | vlassisemm | — | — | Venue — third-party dep (gemini/codex CLI) | **yes** — "the diagnosis is accurate" | **yes** |
| 937 | issue | harrisrobin | — | — | Venue — zero-dependency policy (runtime registry queries) | **yes** — "a real, common friction point" | **yes** |
| 956 | PR | mvanhorn | +87/-0, 2f | main | Venue — bakes `external-delegate: codex` into a core skill; explicitly "a venue call, not a quality judgment" | not disputed | **yes** |
| 968 | issue | bizflix | — | — | Not our defect — traced to OpenCode's own auto-compact/summarization | n/a | **yes** (reopen) |
| 1007 | issue | dfoster-oracle | — | — | Venue — `pack.json` exists only to satisfy one external tool's schema; also moot (aipack `content_paths` already works) | n/a | **yes** (reopen) |
| 1099 | issue | wpf375516041 | — | — | Not our defect — no hardcoded snapshot model ID anywhere in repo history; resolution happens in Claude Code's Task tool | **symptoms yes** — "the symptoms... are real and well known" | no |
| 1109 | PR | kuishou68 | +14/-3, 1f | main | **Integrity** — the "independent verification" is a scripted dual-post by @Bortlesboat (two actions, same second, 2026-04-10T03:50:50Z) | **yes** — "The underlying bug is real"; "a close regardless of whether the diff happens to be correct" | **yes** |
| 1143 | issue | theredsix | — | — | Not our defect — Codex CLI emits one turn twice; tracked at openai/codex#15633 | n/a | no |
| 1166 | PR | manooog | +18/-2, 3f | main | **Integrity** — "Existing PRs" claims none found; author's own #1159 was closed 8h earlier and the diff is byte-for-byte identical | partial — "the surgical-changes idea... isn't without merit" | **yes** |
| 1168 | PR | cnu | +192/-110, 1f | main | Reverts deliberately-tuned content (commit 3f725ff) with no eval evidence; silently drops Visual Companion | no | **yes** |
| 1243 | PR | billioner-lab | +134/-0, 1f | main | Venue — domain-specific (frontend/CSS/a11y); Anthropic already ships `frontend-design` | **yes** — "the skill content itself is solid... nothing factually wrong turned up" | **yes** |
| 1533 | PR | daniel769 | +4/-0, 1f | main | **Falsified by testing** — ran it on CC v2.1.202 twice; the claimed silent failure does not occur | no | **yes** |
| 1569 | issue | meyverick | — | — | Not our defect — Gemini CLI's own auto-router; plugin has no model lever | **pattern yes** — "a real, non-fabricated pattern, not something we doubt" | no |
| 1574 | issue | shizeqin | — | — | Venue — coupling to third-party gstack; precedent #1290 | **yes** — "the writeup is accurate" | **yes** (#1566) |
| 1671 | issue | JV-X | — | — | Venue — DeepEval/Ragas integrations + dashboards are third-party + domain-specific | **yes** — "the underlying observation is accurate" | **yes** (narrowed) |
| 1726 | PR | ElizioMartins | +21/-2, 14f | dev | Bundled unrelated changes (3 issues, 14 files) while answering "No" to the unrelated-changes question | no — duplicates #657 and reintroduces a heredoc deleted in 4e3707f | **yes** |
| 1728 | PR | ElizioMartins | +5202/-2276, 106f | dev | Already resolved on `dev` (#1665 took the *opposite* approach per maintainer's explicit call) | no | no |
| 1781 | PR | zhishuai-G | +104/-0, 6f | dev | **Falsified by testing** — obra ran the exact cited command on the exact cited version (`@2.1.179`); it succeeded | partial — "the guard script itself... is mechanically sound" | **yes** |
| 1797 | issue | specterslient95-lgtm | — | — | **Falsified by testing** — 3 live Sonnet reps; the agent substituted concrete values every time | no | **yes** |
| 1801 | PR | specterslient95-lgtm | +5/-0, 1f | main | **Falsified by testing** (same as #1797, 3 sessions); and the fix wouldn't work even under its own premise | no | no (see #1797) |
| 1817 | issue | AnnaFromPoland | — | — | Not our defect — generic VSCode/Antigravity chrome; Antigravity 2.0 rollout bugs | n/a | **yes** (reopen) |
| 1882 | PR | kht33668944-tech | +60/-32, 3f | main | Deletes the `using-superpowers` Red Flags table + "1% chance" hardening (commits f6ee98a, 2d7408d) with no eval evidence | no | **yes** |
| 1901 | PR | tianma-if | +11/-4, 2f | dev | **Batch** (1 of 10 in 34s); + fabricated reviewer "msh01" | **yes** — "I reproduced the exact reported failures on Asia/Shanghai" | **yes** |
| 1902 | PR | tianma-if | +16/-0, 1f | dev | **Batch**; + "fabricated review attestation, not just a disclosure gap" | **yes** — confirmed the fix in an isolated clone | **yes** |
| 1903 | PR | tianma-if | +12/-0, 1f | dev | **Batch**; + fabricated reviewer; + reverts e7ddc25 | **yes** — "I reproduced both" | **yes** |
| 1904 | PR | tianma-if | +5/-0, 1f | dev | **Batch** — sole substantive reason | **yes** — "cleanly mergeable right now"; content "still checks out" | **yes** |
| 1906 | PR | tianma-if | +30/-0, 2f | dev | Stale premise (the vocabulary it "fixes" isn't in the tree) + re-adds content deleted 9 days earlier in e7ddc25 | no | no |
| 1907 | PR | tianma-if | +2/-2, 2f | dev | **Batch** — "closed for the batch pattern, not the diff" | **yes** — "The link fix itself is correct" | **yes** |
| 1910 | PR | tianma-if | +15/-1, 2f | dev | **Batch** — "The problem isn't the code. The problem is how it arrived." | **yes** — "the underlying bug is real... the regression test is genuine too" | **yes** |
| 1911 | PR | brain-zhang | +1/-0, 1f | main | False core claim — the rule lands in root CLAUDE.md, which `sync-to-codex-plugin.sh` excludes from every packaged build, so it cannot "apply universally" | no — also a stray unmatched double-quote | **yes** |
| 1913 | PR | jemarroyo | +814/-101, 16f | dev | Venue — career/job-search skill; precedent #876 (`building-personal-portfolio`) | **yes** — "Mechanically the PR is clean"; "genuinely well-structured skill" | **yes** (as plugin) |
| 1925 | PR | ashu25252-glitch | +1/-0, 1f | main | **Integrity/null** — the added file is empty (blob `8b13789`), yet "human reviewed the complete diff" is checked | no | **yes** |
| 1937 | PR | FingerLiu | +9706/-130, 108f | main | Fork rebrand (superpowers→ace, owner→Liu Peng) + 108 files of unrelated concerns; blank template for the 3rd time (#1034, #1060) | no | **yes** |
| 1939 | PR | luochen211 | +43/-9, 4f | dev | Fix is wrong — would silently disable SessionStart injection for every user on every OS (reproduced) | **root cause yes** — "That's a real, unaddressed bug" | **yes** (with a spec) |
| 1940 | issue | DAAworld | — | — | No actionable content; wrong venue (Discord for open-ended questions) | n/a | **yes** (reopen) |
| 1944 | PR | tanurus | +2265/-16, 16f | main | Venue — wraps external `claude`/`gemini` CLIs as subprocess workers; also re-adds `gemini-tools.md` removed in 711d895 | no | **yes** (split) |
| 1950 | issue | jacob-arlington | — | — | Not our defect — AVG blocked `Codex.exe` reaching `raw.githubusercontent.co` (look-alike phishing domain); explicitly "a **venue call**" | n/a | no |

---

## 4. Ranked kill reasons — hand-coded primary causes

Each of the 42 is assigned exactly one primary. Counts sum to 42.

| rank | primary reason | n | PRs/issues |
|---|---|---|---|
| 1 | **Venue — belongs in a standalone plugin, not core** | **10** | 683, 730, 937, 956, 1007, 1243, 1574, 1671, 1913, 1944 |
| 2 | **Batch / spray-and-pray** | **9** | 627, 634, 640, 1901, 1902, 1903, 1904, 1907, 1910 |
| 3 | **Not a Superpowers defect** (external tool is the cause) | **6** | 968, 1099, 1143, 1569, 1817, 1950 |
| 4 | **Premise or fix falsified by direct testing** | **5** | 1533, 1781, 1797, 1801, 1939 |
| 5 | **Integrity — a false statement in the submission** | **4** | 1109, 1166, 1911, 1925 |
| 6 | **Reverts/deletes deliberately-tuned content w/o evals** | **3** | 1168, 1882, 1906 |
| 7 | **Already resolved / superseded on `dev`** | **2** | 597, 1728 |
| 8 | **Bundled unrelated changes** | **1** | 1726 |
| 9 | **Fork-specific rebrand** | **1** | 1937 |
| 10 | **No actionable content** | **1** | 1940 |

Rank-1 breakdown (venue): third-party dependency → 730, 937, 956, 1007, 1574, 1944 (6);
domain-specific/out-of-scope → 683, 1243, 1913 (3); both → 1671 (1).

### Secondary reasons (present anywhere in the closure)

| secondary | n | items |
|---|---|---|
| Targets `main` instead of `dev` *(from `gh` metadata, not text)* | **16 of 28 PRs** | 627, 634, 640, 683, 956, 1109, 1166, 1168, 1243, 1533, 1801, 1882, 1911, 1925, 1937, 1944 |
| PR template blank or materially incomplete | **12** | 627, 634, 640, 1109, 1168, 1243, 1801, 1882, 1925, 1937, 1939, 1944 |
| Re-adds or reverts content the maintainer deliberately deleted (git archaeology) | **7** | 634, 1168, 1726, 1882, 1903, 1906, 1944 |
| Fabricated or false identity/review attestation | **7** | 1109, 1901, 1902, 1903, 1906, 1910, 1925 |
| Falsely claims no prior/existing PRs were found | **2** | 1166, 1728 |
| Stale branch / mechanical conflict held *against* the author | **4** | 634, 640, 1166, 1726 |
| Stale branch / conflict explicitly **excused** (obra's own history rewrite) | **3** | 1904, 1913, 1937 |
| Cites ≥1 prior PR/issue/commit by identifier | **38 of 42** | all except 1533, 1569, 1671, 1950 |
| Carries the "closures can be revisited" footer *(string-checked)* | **16 of 42** | 597, 683, 730, 937, 968, 1007, 1099, 1143, 1243, 1569, 1574, 1671, 1817, 1913, 1940, 1944 |

---

## 5. Fatal vs survivable

### Fatal as the SOLE cause — the code was conceded correct and it died anyway

This is the sharpest signal in the corpus. Four closures state, unambiguously, that the diff was
correct and would have been welcome, and close it anyway.

**#1904** — the *purest* case. Nothing else is wrong with it:

> "Re-checked this against current dev (v6.1.1) — it's cleanly mergeable right now, so no rebase is
> needed... The content itself still checks out too... **The reason this is closing is separate from
> both of those:** it's one of ten PRs (#1901-#1910) opened from the same session within a 34-second
> window."

**#1907**:

> "**The link fix itself is correct** — evals/ is gitignored and the replacement URL resolves — **so
> this is being closed for the batch pattern, not the diff.**"

**#1910**:

> "To be clear up front: the underlying bug is real... **The problem isn't the code. The problem is
> how it arrived.**"

**#1109** — integrity, stated as sole-sufficient:

> "Under our contribution policy that's a close **regardless of whether the diff happens to be
> correct**."

**Fatal on its own: (a) batch membership, (b) any false statement in the submission.** Nothing else
in the corpus is shown killing a conceded-correct diff.

### Never fatal alone — the survivable set

- **Targeting `main`.** 16 of 28 PRs did it. It is *never* the primary. **#956** says so outright:
  "this targets `main` and we land on `dev`, but that's just housekeeping, not why we're closing."
- **Merge conflicts / stale branch.** Cuts both ways, and in three cases obra *apologises for it*:
  "dev's history was recently rewritten, so please don't read the CONFLICTING state or the
  're-added' doc files as anything you did wrong" (**#1937**); "the other 15 files in `gh pr diff`
  are a stale-fork artifact... not bundled changes" (**#1913**). Conflicts only count when they
  reveal that the content is wrong for the current tree (#634, #640, #1166, #1726).
- **Blank template.** Present in 12 closures, never the sole cause — it is always stacked with
  batch, venue, or a false claim. But note: it is never *excused* either, and #1801 says "either
  alone is grounds to close without review per CONTRIBUTING."
- **Size.** Ranges from +1/-0 (#1911, #1925) to +9706/-130 (#1937). Both extremes died. Size does
  not predict outcome.

### The "batch" number, precisely

**3 distinct incidents. 10 of the 42 closures. Only 2 of the 3 are in-repo spray-and-pray.**

**Incident 1 — `stablegenius49`, 2026-03-06, `pr-factory/issue-NNN-*`.**
Twelve PRs (#627–#640) in ~6 hours, each against a different unrelated issue. Obra enumerates them:
"#627, #628, #629, #630, #631, #632, #634, #635, #637, #638, #639, #640" (**#634**). Only #631 (a
one-line link fix) ever merged. **Three appear in this corpus: #627, #634, #640.** Tells beyond
volume: `pr-factory/` branch names (verified — all three head branches are `pr-factory/issue-593-…`,
`pr-factory/issue-446-…`, `pr-factory/issue-485-…`), zero template sections completed, all targeting
`main`.

**Incident 2 — `tianma-if`, 2026-07-03, 04:19:42–04:20:16Z.**
Ten PRs (#1901–#1910) in a **34-second window** — "one every 3-4 seconds, spanning unrelated
subsystems" (**#1903**). **Seven appear in this corpus: #1901, #1902, #1903, #1904, #1906, #1907,
#1910.** Tells: every PR carries an identical disclosure block naming **"msh01"** as "the human
partner who reviewed this diff" — "**but GitHub shows the actual head repo owner is your own account
(tianma-if), and there is no GitHub user named msh01**" (#1901); the identical framing line "user
asked to find real, high-quality contribution candidates for Superpowers"; and **#1907** quotes the
template answer that hangs them: "Eval sessions run after the change: **0**." Verified from
metadata: all ten head branches are `codex/*`, all target `dev`, all are ≤ +30 lines. Obra's own
articulation of why volume alone is disqualifying: "**No one reviewed ten independent cross-cutting
diffs in 34 seconds**" (#1903).

**Incident 3 — `kuishou68` / #1109, cross-repo drive-by.** Not a superpowers batch; a *pattern-of-
account* batch: "five near-identical 'fix:' PRs across five repos in under six minutes on
2026-06-01." It counts as a batch tell because obra used it as evidence, but it produced only **one**
closure here.

**Near-misses that are NOT batches** (and were probably what inflated the bad regex count):
**#1726** (one author, 3 unrelated changes in *one* PR — that's *bundling*, a different rule),
**#1925** (2 PRs 3 minutes apart, characterised as "exploration of GitHub's UI", not spray-and-pray),
**#1937** (3 blank-template attempts over 3 *months* — repetition, not a burst).

---

## 6. The two verdict tracks

Obra's triage runs two disjoint tracks, and they are marked. **The footer is the marker.**

### Track A — "Venue call" (16 closures)

Marked by: *"If you think this call is wrong, reply here — Jesse reads these, and closures can be
revisited."* — #597, #683, #730, #937, #968, #1007, #1099, #1143, #1243, #1569, #1574, #1671, #1817,
#1913, #1940, #1944. Also self-labelled in the text of #956 ("a venue call, **not a quality
judgment**") and #1950 ("closing as a **venue call**") — those two carry the label without the
footer.

The submission is *fine*. It is in the wrong place. The verdicts read as redirection, praise the
work, and name the correct home (standalone plugin, the upstream tool's tracker, Discord). Track A
closures overwhelmingly concede correctness: #1243 ("nothing factually wrong turned up"), #1913
("genuinely well-structured skill"), #730 ("the diagnosis is accurate").

### Track B — Quality / integrity (26 closures)

**No footer. Ever.** The verdicts read as findings: a false claim, a fabricated reviewer, an
unreproducible premise, a revert of tuned content, a batch. The retry invitation, where offered, is
conditional on *fixing the behaviour*, not on relitigating the call: "with honest disclosure of who
reviewed it" (#1902), "from the account that will own it" (#1910), "with a genuine human review pass"
(#1903).

**What distinguishes them:** Track A is about *where the work belongs*. Track B is about *whether the
submission told the truth and whether the claim survives being run*. A Track A closure is an
invitation to relocate. A Track B closure is a finding about the submitter.

---

## 7. Every retry invitation, verbatim

These are pre-approved specs. Someone has already tested the claim, confirmed the bug, and written
down what an acceptable submission looks like. This is the highest-value content in the corpus.

**#627** — "a single, template-complete resubmission with disclosure and real eval sessions showing
the new wording changes triggering or response quality would be welcome."

**#634** — "If a verification checklist is still worth adding, it would need a fresh, single,
human-reviewed PR against `dev`, written against the current README structure, with the template
fully completed."

**#683** — "If you do publish it, two things to fix first: it targets main (core PRs go to dev), and
SKILL.md hardcodes `~/.claude/plugins/cache/.../superpowers/5.0.0/...` in two places... Happy to
point you at the plugin-packaging docs."

**#730** — "the core-compatible shape is a generic, zero-dependency hook/extension point in the
review pipeline that a standalone plugin can attach to — not a built-in Codex/Gemini integration...
happy to see the hook-point idea filed separately if there's interest in keeping it alive."

**#937** — "If you build it as a standalone plugin, we'd welcome a link in the README's community
plugins list. Separately, if there's appetite for a much lighter, network-free version — e.g. a
one-line reminder in writing-plans to flag cited package versions as unverified against training
data — that could be proposed on its own as a narrower issue."

**#956** — "The better home is a standalone plugin attaching through that generic extension point."

**#968** — "if this still happens with Superpowers disabled, it's one for OpenCode directly...; if it
happens ONLY with Superpowers enabled, comment here with that detail and we'll reopen and dig in."

**#1007** — "Closing as out of scope for core; reopen if `content_paths` turns out to be insufficient
for something specific."

**#1109** — "If someone wants to fix #1108 for real, a single scoped PR against `dev` that completes
the template is welcome, and #1106/#1562 are the prior art to reconcile with."

**#1166** — "If you want to pursue the surgical-changes idea, it isn't without merit, but it needs a
fresh PR against `dev`, honest 'Existing PRs' disclosure, and real eval evidence (transcripts, not
summaries) per the writing-skills process."

**#1168** — "If there's a real triggering problem you've observed, please reopen with a session
transcript, run it through `superpowers:writing-skills` with before/after evals, and use the PR
template."

**#1243** — "Happy to reconsider if there's a gap the existing plugin doesn't cover, but as scoped
this looks like the wrong venue for core."

**#1533** — "Happy to take another look if you can attach a literal transcript reproducing a silent
failure on a current version."

**#1574** — "If you'd rather see a vendor-neutral extension point than a gstack-specific one, #1566
(lifecycle extension system) is the right place for that shape."

**#1671** — "a narrower ask — a pure EDD-methodology skill with no framework integrations or
dashboarding, grounded in the specific session where you hit the gap — would be a smaller, more
tractable proposal worth its own issue."

**#1726** — "If you'd like to contribute further, one focused, rebased PR per issue with an accurate
'unrelated changes' answer is the way to do it."

**#1781** — "Closing for now; happy to reconsider if you can attach an actual transcript showing the
rejection on a currently-supported Claude Code build."

**#1797** — "Closing #1797 and #1801... unless someone can produce a transcript where it actually
happens."

**#1817** — "if you retry on the current Antigravity IDE release and it still reproduces, comment
here and we'll reopen."

**#1882** — "If you've hit a concrete session where the current wording caused a bad over-trigger,
describe it, retarget `dev`, complete the template, and bring before/after eval results and we're
glad to look again."

**#1901** — "If you resubmit, do it as a single PR with accurate identity disclosure; the underlying
fix (TZ=UTC on archive creation, plus reading raw tar mtime instead of localized `tar -tv` text) is
sound and would very likely be welcome on its own."

**#1902** — "If an actual person wants to resubmit this specific one-file fix on its own, with honest
disclosure of who reviewed it, it's a welcome, correct change."

**#1903** — "please resubmit as a single PR with a genuine human review pass... A trim of the test's
assertions (or a one-sentence legacy-vocabulary note) would fix the real breakage without reverting
that decision."

**#1904** — "Happy to look at this specific doc fix again as a standalone submission."

**#1907** — "If you actually hit the broken link and want it fixed, open a single PR motivated by the
specific session where it tripped you up (and please include the identical CLAUDE.md line-104
reference), rather than a batch of scattered candidates."

**#1910** — "The worktree fix is worth keeping: please reopen it as a single, standalone PR from the
account that will own it, with the disclosure table matching that account, and we'll evaluate it on
its own merits."

**#1911** — "If you want to pursue the underlying idea, it would need to be either your own project's
instructions file, or a proper skill addition with Superpowers-specific eval evidence."

**#1913** — "Please publish this as a standalone plugin — genuinely well-structured skill, just not a
fit for core."

**#1925** — "happy to look again if you come back with a real change and a completed template."

**#1937** — "Please retarget dev, split out one scoped, template-complete PR for whichever feature
you want reviewed with the rebrand removed, and publish the Feishu/ACE pieces as their own plugin."

**#1939** — "A fix that keeps `${CLAUDE_PLUGIN_ROOT}` but switches to exec form (args) instead of a
quoted shell-form string looks like the right direction — worth trying next."

**#1940** — "Closing this one for lack of actionable content; happy to reopen with specifics." (A
token/rollout table like the one in #1152 is named as the useful artifact.)

**#1944** — "If you want to pursue it, split that piece out, target `dev`, complete the template with
disclosure, and bring eval evidence per the skill-change policy; ship the external-CLI workers as a
standalone plugin."

**Count: 33 of 42 closures carry a retry invitation.** The 33 above are quoted in full; #1797's is
phrased as a challenge ("unless someone can produce a transcript where it actually happens") and I
counted it as an invitation.

**No retry offered — 9:** #597, #640, #1099, #1143, #1569, #1728, #1801, #1906, #1950. These are the
closures where the door is shut: superseded (#597, #1728), the bug lives in someone else's tool
(#1099, #1143, #1569, #1950), or the premise itself was false and the author had already been told
(#640, #1801, #1906).

---

## 8. What they actually verify

This is what "every factual claim tested against the current `dev` tree, then adversarially
re-checked by a second, independent agent" (#1904) means concretely. Enumerated from the closures:

**They check whether a named human reviewer's GitHub account exists.**
> "every PR in that batch, including this one, states 'Head: msh01/superpowers' and 'Human partner
> who reviewed this diff: msh01' — but GitHub shows the actual head repo owner is your own account
> (tianma-if), and **there is no GitHub user named msh01**." — **#1901**. Escalated in **#1902** to
> "that's a **fabricated review attestation**, not just a disclosure gap."

**They check whether a claimed independent verifier is an independent party.**
> "The 'independent verification' here isn't independent. @Bortlesboat's only two actions in this
> entire repo are confirming #1108 and reviewing #1109, and both were posted at the exact same second
> (2026-04-10T03:50:50Z) on two different issues — that's a scripted dual-post, not someone reading
> and reviewing." — **#1109**

**They run the test suite, on the exact version cited.**
> "I ran the exact command against the exact cited version — `npx @anthropic-ai/claude-code@2.1.179
> -p "say ok" --max-turns 1 --output-format stream-json` — and it completed successfully with no
> `--verbose` and no error. I also ran the current, unpatched `tests/explicit-skill-requests/
> run-test.sh` end-to-end against Claude Code 2.1.202... it passed cleanly." — **#1781**

**They reproduce the bug, and then reproduce the fix, in a clean checkout.**
> "`node --test tests/pi/test-pi-extension.mjs` does fail on dev right now with exactly the `/write/`
> AssertionError you quoted, and your patch does make all 6 tests pass - **I reproduced both**." —
> **#1903**. And **#1901**: "I reproduced the exact reported failures on Asia/Shanghai against current
> dev."

**They run live agent evals against the claim.**
> "Fresh Sonnet sessions got the real Step 1b text from dev and no native worktree tool (your
> scenario), with a neutral task prompt that never hinted at the expected failure. **Across 3
> independent reps** (different tasks/fixture repos), the agent... substituted concrete values every
> time... never leaving `$LOCATION`/`$BRANCH_NAME` unexpanded." — **#1797**

**They do git archaeology on whether a PR re-adds deliberately-deleted content.**
> "this PR re-adds content — the exact `update_plan` mapping and the `~/.codex/skills`/
> `~/.agents/skills` note — that the maintainer **deliberately deleted 9 days before this PR was
> opened** (commit e7ddc25: 'restated guidance modern agents already follow')." — **#1906**
> Also: **#1168** (commit 3f725ff), **#1882** (f6ee98a, 2d7408d), **#1944** (711d895), **#1726**
> (4e3707f), **#634** (April's Codex-cleanup pass).

**They perform a real test-merge and read the result in context.**
> "a real test merge against current `main` drops the new 'Claude Code checklist' text right after
> the unrelated Pi install instructions, disconnected from anything about Claude Code." — **#634**

**They diff the new submission against the author's previously-rejected one, by blob hash.**
> "The skill-content diff here is **byte-for-byte identical to #1159 (same blob hashes for all three
> files)**; nothing changed in response to the rejection except the PR template text." — **#1166**

**They check that the claimed evaluation is reflected in the diff.**
> "The new 'Evaluation' section describes adversarial sessions and specific outcomes, but even the
> gap it names ('orphan cleanup is still inconsistent') isn't reflected in the diff — no additional
> reminders were added." — **#1166**

**They cross-reference the author's other PRs, in this repo and others.**
> "This account's PR history is also drive-by across unrelated projects — five near-identical 'fix:'
> PRs across five repos in under six minutes on 2026-06-01." — **#1109**
> "Combined with #1924 (same author, 3 minutes earlier: an unrelated boilerplate package-lock.json
> from a fresh Codespace), this reads as exploration of GitHub's UI rather than an intended
> contribution." — **#1925**

**They check the actual content of the added file.**
> "the added file 'AI Agents' is **empty (a single blank line, git blob 8b13789...)**, and none of the
> required template sections are filled in... The 'human reviewed the complete diff' and 'reviewed
> existing PRs' boxes are checked but contradicted by the content." — **#1925**

**They check whether the fix actually works where it will run.**
> "I reproduced it: `./hooks/run-hook.cmd session-start` fails with 'No such file or directory' from
> any directory other than the plugin's own checkout... **Merging this would silently disable
> SessionStart context injection for every user on every OS.** The new test doesn't catch this
> because it `cd`s into the plugin root before invoking the relative command, which isn't how Claude
> Code actually runs it." — **#1939**

**They test the plausibility of the environment table.**
> "Superpowers' first commit is 2025-10-09, so 'pulled 2025-06-01' predates the project by four
> months, and it has only ever shipped as one plugin ('superpowers'), never a 'core/git/shell/test'
> split — please refile with what you actually observed." — **#1671**

**They search the whole repo and its full history to falsify the premise.**
> "I checked subagent-driven-development's dispatch templates and the repo's full history: **there's
> no hardcoded snapshot model ID anywhere.**" — **#1099**
> "I searched the full repo and its entire git history and that `.co` domain never appears
> anywhere." — **#1950**

**They read the screenshot.**
> "The AVG dialog shows it blocked a connection to `raw.githubusercontent.co` (note: `.co`, not
> `.com` — a look-alike phishing domain), made by `Codex.exe`." — **#1950**

**They trace the bug into the third-party tool's own source.**
> "a follow-up comment there traces the cause to ambiguity in Codex's own prompt contract
> (`codex-rs/models-manager/prompt.md`)." — **#1143**

**They read the commit authorship trailer.**
> "Commit authorship (SeniorEngineer/Paperclip <@paperclip.ing>) points to an autonomous multi-agent
> platform rather than a reviewed human session." — **#1168**

**And they distinguish real conflicts from conflicts they caused.**
> "the other 15 files in `gh pr diff` are a stale-fork artifact (your branch's merge-base with dev is
> 10 commits behind), **not bundled changes**." — **#1913**

---

## 9. So what

1. **A correct diff is not sufficient and is not even close.** Four closures concede the code was
   right and close anyway (#1904, #1907, #1910, #1109). Correctness buys you a polite paragraph.
2. **One submission at a time. Ever.** Batch is 9 of 42 primaries and is the *only* thing shown
   killing an otherwise-perfect PR on its own (#1904: cleanly mergeable, content verified, closed).
   Ten PRs in 34 seconds (#1901–#1910) and twelve in six hours (#627–#640) both died in full.
3. **Every factual sentence in the body will be executed.** They ran the cited npx command at the
   cited version (#1781), diffed against your prior rejected PR by blob hash (#1166), looked up your
   named human reviewer on GitHub (#1901), and read the file you added to find it empty (#1925). Do
   not write a sentence you have not personally verified in the last hour.
4. **Never name a reviewer who cannot be found, and never claim a verification you did not get.**
   Fabricated attestation is the other sole-sufficient kill (#1109, #1901–#1910, #1925), and it is
   the only category where the tone turns cold and the "closures can be revisited" footer disappears.
5. **Venue is the single largest bucket (10 of 42) and it is decided before your code is read.**
   Third-party dependency or domain-specific → standalone plugin, every time, with precedent cited
   (#61, #876, #1005, #1290, #646). Check venue *first*; a good skill in the wrong repo is a wasted
   week (#1243, #1913).
6. **`main` vs `dev` is noise.** 16 of 28 PRs targeted `main` and it is never the reason (#956:
   "just housekeeping, not why we're closing"). Fix it, but do not believe it is what killed anyone.
7. **Do not touch tuned content without evals.** Red Flags tables, trigger descriptions, "1% chance"
   language — 3 primaries and 7 secondaries. They know the SHA that added it and will name it
   (#1168/3f725ff, #1882/f6ee98a, #1906/e7ddc25). Git archaeology is a *routine* check here.
8. **"By inspection" is a confession.** #1797 died because the reporter answered Jesse's "did you hit
   this?" with "By inspection" — and the triage then ran it 3× live and it didn't happen. Bring a
   transcript or don't file.
9. **The retry invitations in §7 are free, pre-approved work.** #1901 (TZ=UTC on archive creation),
   #1910 (worktree `.git`-is-a-file), #1902 (antigravity test fix), #1939 (exec-form hook command) —
   each is a confirmed-real bug with a maintainer-written spec and an explicit "would be welcome",
   sitting unclaimed because the original submitter burned the PR.
10. **The 14 issue closures are a different game from the 28 PR closures.** Six of them are "not our
    defect" — the bug was in OpenCode, Codex, Gemini CLI, Antigravity, or Claude Code itself.
    Superpowers is a pile of prompt files; before filing, disable it and check whether the symptom
    survives (#968 spells out this exact test).
