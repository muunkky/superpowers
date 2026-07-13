# Credibility ledger — obra/superpowers

**Read this before engaging upstream. Update it after every upstream interaction.**

This is the scoreboard for the whole strategy. The bet is that *being visibly the best contributor in the
room* compounds: people cite you, people take your review notes, and eventually the maintainer reads your
PR with a prior that it's worth his time. That bet is either paying off or it isn't, and the only way to
know is to write down what actually happened rather than what we hoped would happen.

**Be ruthless here.** A ledger that only records wins is a mood board. Log the silence and the closes too —
silence at a repo with 178 open PRs is *data about the repo*, not a verdict on us, and knowing the
difference is the entire value of keeping this.

---

## Scoreboard — as of 2026-07-13

| Signal | Count | Notes |
|---|---:|---|
| **PRs merged (ours)** | **0** | 4 open, none reviewed yet |
| **Our work merged via someone else's PR** | **2 items** | Operator docs + injection test, folded into #1964 |
| **Public endorsements from contributors** | **1** | @aznikline, unprompted, on #1964 |
| **Citations of our work by others** | **1** | #1979 cites #1927 twice as closest prior art |
| **Defects we caught in others' PRs** | **3** | #1976 (test-breaking regression + duplicate of obra's own PR), #1899 (stale hunk), #1964 (wrong base branch) |
| **Maintainer (@obra) responses to us** | **0** | No signal either way. He has 178 open PRs and merged 6 since 2026-07-01. |
| **PRs closed/rejected** | **0** | (3 self-withdrawn and reopened — our own error, not his) |

**Baseline for calibration:** ~178 open PRs, ~6 merged in the first two weeks of July. **A ~3% movement
rate means silence is the default state, not a rejection.** Do not read nothing as a no.

---

## The ledger

Newest first. One row per real signal, with the evidence link. If you can't link it, it didn't happen.

### 🟢 #1979 — another contributor cites #1927 as prior art (2026-07-13)

@Lady-Lin filed [#1979](https://github.com/obra/superpowers/issues/1979) hours after our #1927 comments,
citing it **twice** as the closest existing report:

> *"The closest reports are #1927 (closing completed Codex agents) and #1633…"*
> *"#1927: close completed Codex subagents after consuming results."*

**Why it matters:** an independent contributor mapping the Codex-lifecycle problem space treats #1927 as a
landmark. Our PR #1982 is the one that lands it. Their issue is *complementary* (mailbox/liveness during
work) rather than competing (release after work).

**Bonus — it independently validates our design.** They document a controller that inferred `BLOCKED` from
a `wait_agent` timeout and interrupted a healthy child. Our release rule is deliberately **status-blind**
for a cousin of that exact reason: inferring agent state from indirect signals is unsafe.

### 🟢 #1964 — @aznikline folds our work in and thanks us publicly (2026-07-13)

The single most valuable thing on the record. Unprompted, in public:

> *"@muunkky — really nice writeup, and a strong signal to see two independent passes converge on the same
> tokenizer → `execFile` shape. **I folded both of your bits straight into #1964** (appreciate you offering
> them as a follow-up rather than competing)…"*

**What happened:** a competing PR landed the same core fix *while we were building*. Instead of opening a
rival PR, we offered our extras additively — operator docs and a shell-injection test. They took both, and
**our `dev`-vs-`main` flag fixed their PR's base branch.**

**The lesson, and it is the most important one in this file:** *deferring* to the first PR and contributing
to it outperformed competing with it. Our code is going upstream inside someone else's PR, and we gained an
ally instead of a rival.

### 🟡 #1976, #1899 — review notes posted, no response yet (2026-07-13)

Caught, with proof, in other people's PRs:
- **#1976** — a repo-wide `exec`→`execFile` sweep that **breaks an existing test on `dev`** (reproduced:
  13 pass/0 fail → 12 pass/1 fail), *and* duplicates obra's own open PR #1805, *and* targets `main`.
- **#1899** — a hunk that went stale when #1959 merged; it would delete a *working* import.

No replies yet. Value is banked regardless: these are on the record as careful, evidenced reviews.

### ⚪ Our four PRs — open, unreviewed (2026-07-13)

[#1982](https://github.com/obra/superpowers/pull/1982) (#1927) ·
[#1983](https://github.com/obra/superpowers/pull/1983) (pi test) ·
[#1984](https://github.com/obra/superpowers/pull/1984) (#1481) ·
[#1985](https://github.com/obra/superpowers/pull/1985) (#666)

All open, out of draft, mergeable, template-complete. **Three of the four are fixes obra personally specced
or invited** in closing comments nobody else went back and read. Each was socialized on its own issue
thread before any code was written.

**Self-inflicted wobble worth remembering:** all four were opened within 22 minutes, we panicked about the
batch rule, self-closed three, then reopened them with notes pointing at the prior socialization. Net
effect is probably neutral-to-positive (it demonstrates we police ourselves), but it was churn we caused.

---

## 🔴 Negative signals — log these first, and log them honestly

**A ledger that only records wins is a mood board.** The negatives are the ones that change behaviour, so
they get their own section and they go in *before* the wins. Record the maintainer's exact words when a
thing is closed or criticized — paraphrasing a rejection is how you fail to learn from it.

### Rejections / closes received from upstream

**None yet.** (No PR of ours has been closed by a maintainer.)

> When this happens: log the **verbatim** closing comment, the reason class (slop / batch / scope / tuned
> content without evals / duplicate / wrong base), and what we'd do differently. A close is the most
> information-dense event available to us — it is worth more than five silent PRs.

### Criticism / pushback received

**None yet.** No one has told us we're wrong, noisy, or unwelcome.

### Own goals — mistakes we made, caught ourselves

| Date | What we did | Cost | Caught by |
|---|---|---|---|
| 2026-07-13 | **Opened 4 PRs in 22 minutes.** Exactly the batch pattern upstream closes *regardless of merit* — on the same morning we quoted that rule at another contributor. | Self-closed 3, reopened them with notes pointing at prior socialization. Churn on 4 threads. Probably neutral, possibly a small positive (self-policing is visible). | Us, before any maintainer saw it |
| 2026-07-13 | An executor delivered the pi fix as a **73-line rewrite with helper functions** when obra had asked for *"a trim."* This is the exact over-engineering that got #668 and #1903 closed. | Caught at review; reset to a 1-line change. Would have been closed on sight. | Our own review gate |
| 2026-07-13 | **Comments read like a bot wrote them** — 4,000-character posts, headers, tables, half-bolded sentences, and narration of our own review process ("four adversarial review rounds"). Disclosures varied between comments. | Rewrote all five posted disclosures to one identical line; stripped the process narration. The long comments remain — churning edits across 4 threads would look worse. | The human partner, angrily |

### Standing risks — things that could still sink us

| Risk | Where | Severity |
|---|---|---|
| **We cannot run the eval harness at all** (no `tmux`, `evals/` not cloned, no `codex` CLI). Upstream demands eval evidence for behaviour-shaping skill content. | Structural. Affects every skills PR we will ever open. | **High** — this is our biggest permanent weakness |
| **#1982 touches tuned content** (adds a Red Flags bullet) **with zero evals.** We disclosed it and offered to drop it, but it is on the close-on-sight list. | [#1982](https://github.com/obra/superpowers/pull/1982) | High |
| **Four PRs open at once** from an account with no merge history. Individually justified; collectively it still *looks* like volume. | All four | Medium |
| **Zero maintainer contact.** We have no relationship with @obra. Every judgment we make about what he wants is inferred from his writing, not from him. | Everywhere | Medium |

---

## What's working vs. what isn't

| Play | Attempts | Result |
|---|---:|---|
| **Additive review on someone else's PR** | 3 | **1 confirmed acceptance + public thanks, 0 rejections** |
| **Answering the maintainer's own written spec** (mining closed-PR comments) | 3 | Sourced 3 of our 4 PRs; unproven until reviewed |
| **Our own PRs** | 4 | 0 reviewed. Sitting in a pile of 178. |

**The read:** credibility is being built in *other people's threads*, not in ours. At a repo with a 3%
merge rate and an underwater maintainer, improving someone else's PR is cheap for them to accept and hard
for anyone to dismiss. Our own PRs are a slower, higher-variance bet — worth making, but not the engine.

**So: keep opening PRs** (the process is sound and the work is good), **but keep helping on other people's
PRs as the primary engine of standing.**

---

## What to log here

**Positive:**
- **Citations** — anyone referencing our issues, PRs, comments, or findings.
- **Endorsements** — a human saying our work was good, or taking it.
- **Acceptances** — our code merged, ours or inside someone else's PR.
- **Defects we caught** in others' work, and whether they were acted on.
- **Relationships** — who replies to us, who we've helped. These compound.

**Negative — these matter MORE, and they go in first:**
- **Closes and rejections**, with the maintainer's reason **verbatim**. Never paraphrase a rejection.
- **Criticism and pushback** — anyone telling us we're wrong, noisy, sloppy, or unwelcome.
- **Own goals** — mistakes we made and how they were caught. Write these down even when nobody outside
  saw them; the near-miss is the cheapest lesson available.
- **Standing risks** — the structural weaknesses that will keep costing us until they're fixed (e.g. we
  cannot run evals, so every behaviour-shaping change is exposed).
- **Silence, with its baseline.** Note the repo's merge rate alongside it. Silence at ~3% movement means
  nothing about us; silence at 80% would mean everything. Without the baseline you'll misread it.

**Maintainer responses of any kind** are the scarcest signal here — log every one, praise or otherwise.

## What NOT to log

Vanity. Lines of code, PRs opened, hours spent, docs produced. **Volume is an input, not a signal.** The
only entries that belong here are ones where *someone else did something* because of what we did — or
where *we did something we should not repeat*.
