---
name: contributing
description: >
  REQUIRED for ANY interaction with the obra/superpowers upstream — this repo is a fork, and
  every outward-facing action goes through this playbook. Load it BEFORE you: post or edit ANY
  upstream comment (on an issue OR on someone else's PR — the additive review is our
  highest-value play); open, close, reopen, retarget, or update a PR; reply to a review or to
  the maintainer; file an issue; push a branch; sync the fork; build a fork showcase; or decide
  whether to engage with an issue at all. Also load it when the user says "push this up", "open
  the PR", "contribute this", "send it to obra", "comment on that issue", "help on their PR",
  "should we take this one?", or asks how the local→fork→upstream split works. It carries the EIGHT
  ANTI-PATTERNS that actually get PRs closed there (84.5% are) — assertion instead of execution;
  amnesia about why the code is that way; fabricated attestation (they look up your named reviewer
  and check whether the account exists); volume over care; blaming superpowers for another tool's
  bug; venue blindness; sounding like a bot; and NOISE (comments about you, not their code). The triage is a groundedness detector, not a code
  review — a correct diff does not save you. Also: socialize-before-you-build; the one-line
  disclosure; the clean code-only branch off `dev`; keeping gitban artifacts and `.claude/` on the
  fork only; and the credibility ledger. Pairs with `gitban-pr`, which writes the PR body.
---

# Contributing — local → fork → upstream

## Day one — do these in this order

**A fresh clone is unsafe until step 1.** Do not skip it because the repo "looks fine": the guardrail that
keeps our artifacts out of an upstream PR does not travel through git, so on a new clone it does not exist.

```bash
.claude/skills/contributing/fork-setup.sh          # 1. make the clone safe. FIRST COMMAND, ALWAYS.
.claude/skills/contributing/selftest.sh            # 2. prove the playbook's controls actually work
.claude/skills/contributing/check-upstream.sh --all  # 3. every thread we've already touched
```

4. **Read [`CREDIBILITY.md`](CREDIBILITY.md)** — what has actually worked, and what we are not allowed to
   repeat. Its *Baseline* table is the only place measured numbers live; nothing else here restates them.
5. **Pick work from *Where the free work is* (below), not from the issue tracker.** Trawling the tracker is
   the single most reliable way to get closed.
6. **Then follow *The sequence*, and never post anything without the gate** (*⛔ NEVER POST DIRECTLY*).

Everything else in this file is **reference**. Read a section when you reach the step that names it.

| File | What it is |
|---|---|
| `SKILL.md` (this) | The playbook: how the fork works, what gets you closed, how to post. **Guidance.** |
| `CREDIBILITY.md` | The scoreboard: what happened, what worked, the measured baseline. **State.** |
| `fork-setup.sh` | Makes a clone safe. Idempotent. Run once per clone. |
| `preflight.sh` | The mechanical gate. `--text` a comment, `--body` a PR body, bare = audit live PRs. |
| `check-upstream.sh` | Sweeps every thread we've touched for replies. |
| `selftest.sh` | Regression suite for the controls above. Run it after editing this skill. |

**The cast:** *obra* is Jesse Vincent, the maintainer — he triages, and he is the one who closes things.
*arittr* is the other frequent committer. *muunkky* is this fork. Where this file says "we", it means the
people who ran this playbook before you; where it says **2026-07-13**, it means one bad session in which we
committed five of the eight anti-patterns below in a single morning — every control in this directory exists
because of something that went wrong that day, and the receipts are in `CREDIBILITY.md`.

**One warning about this file's own voice.** It is written for an agent's attention — heavy bold, dense
em-dashes, hammering repetition. **Do not imitate it.** What you post upstream must look nothing like what
you are about to read: plain prose, short, no headers, no bold. See anti-pattern 7.

This repo is a **fork** of someone else's project. Almost every mistake here is a *leak* — fork
tooling or lifecycle artifacts bleeding into what should be a tight upstream contribution, or an
edit to a tracked upstream file that causes merge pain later. One rule prevents nearly all of it:

> **git tracks the code. gitban's artifacts and our `.claude/` tooling live beside it. The
> upstream PR is a clean slice of code only. The fork carries everything — code, tooling, and the
> whole gitban story.**

Internalize that and "what goes where" answers itself — you never decide file by file.

## Two destinations, two postures (the core principle)

The fork and the upstream are **not symmetric**, and the whole workflow falls out of that:

- **The fork push is standard and unconditional.** Your fork is your own space — near-zero risk. The gitban
  process always produces the same artifacts, and they always get published the same way (showcase branch,
  decks, mirror-issue narrative). It's a pipeline you *always* run: your durable record and your staging
  ground. No judgment required.
- **The upstream push is nuanced and conditional — and sometimes you don't push at all.** Upstream is
  someone else's house, with their rules and their people. Every upstream move is a judgment call keyed to
  the situation: which branch (`dev` vs `main`), that repo's specific requirements (template, one-problem,
  no-deps, human review), the mandatory disclosure, and above all the **state of the issue** — a fresh issue
  you socialize and claim, versus a mature one where a competing PR already exists (defer / contribute to
  theirs / just comment) or the maintainer has already steered it.

**So: run the fork pipeline AT THE SCALE THE CHANGE DESERVES, then decide the upstream move — up to and
including "don't."** For most changes that land here (median: 6 lines, 1 file) the fork wave is a showcase
branch and nothing else — **no PRD, no ADR, no design doc, no deck.** Write a planning artifact only when it
will make the diff *smaller* (see *Deep thought, simple solution*). Doing the fork work first is what lets you
make the upstream call from strength — or walk away cleanly from a duplicate. (Real case: #1957 — we published the full fork showcase, then the right upstream move turned out to be a
light comment on someone else's PR rather than one of our own, because #1964 got there first with the same
fix. Our two additions were folded into #1964 and thanked for publicly.)

## ⛔ NEVER POST DIRECTLY. Draft → preflight → verify → post.

**Every upstream comment and every PR body goes through this gate. No exceptions, no "it's just a
one-liner."** Everything we had to retract on 2026-07-13 — a false claim that we couldn't run evals, a
promise we falsified four minutes later, a ticked box we hadn't earned, four self-narrating comments, a
gitban sales pitch in the disclosure — would have been caught here. We posted them because we typed
straight into `gh`.

**1. Draft to a scratch file.** Never compose in the `gh` command. `tmp/comment.md`, `tmp/pr-body.md`.

**2. Run the mechanical check:**

```bash
.claude/skills/contributing/preflight.sh --text tmp/comment.md   # a draft
.claude/skills/contributing/preflight.sh                          # every live PR + thread
```

It greps for the specific things we have actually shipped and retracted: the "can't run evals" lie,
"by inspection", approximate counts, bold saturation, process narration, the gitban pitch, "invents
nothing", and self-narrating noise. **A clean run is necessary, not sufficient** — it only knows the
mistakes we have already made.

**3. Then hand it to an isolated subagent for verification.**

**Brief it NEUTRALLY. Never prime it to attack.** Words like *"hostile"*, *"try to kill this"*, *"find the
lie"* create demand characteristics — the reviewer has to produce findings to satisfy the brief, so it
manufactures or inflates them, and you can no longer tell a real defect from an invented one. **Ask it to
verify, not to destroy.** Then the findings mean something.

> Verify this draft before it goes to `obra/superpowers`, a repo that re-runs every factual claim in a
> submission against the tree. The repo is at `<path>`; `upstream/dev` is fetched.
>
> **Check each claim by executing it, not by reading it:**
> 1. **Numbers** — does every count match `gh pr view <n> --json additions,deletions,changedFiles`?
> 2. **Quotations** — grep each one in the tree. Is it there verbatim?
> 3. **Cited PRs/issues** — is each one's state (open / merged / closed) described correctly *right now*?
> 4. **Behavioural claims** — "this test fails on dev", "the eval showed X". Run them.
> 5. **Ticked boxes** — is each supported by the text and the diff?
> 6. **Named people** — does the GitHub account exist?
>
> **Then as a reader:**
> 7. Does any sentence serve the author rather than the maintainer — their process, their revision history,
>    their feelings about their own PR?
> 8. Would a maintainer recognise this as machine-written and be irritated by it?
>
> Report what you find, with the command you ran and its output. **If a claim checks out, say so. If you
> find nothing wrong, say that** — a clean verdict is a useful result, and inventing a finding to look
> thorough is worse than useless.

**Then verify what it reports.** A reviewer can be wrong in either direction. Re-run its checks yourself
before you act on any of them — especially before you change a diff on its say-so.

**4. Fix what it finds. Re-run. Then post.**

**Why an isolated subagent and not just re-reading it yourself:** you cannot see your own noise. Every
correction we posted today was itself noise, written by the same context that produced the thing it was
correcting. A reviewer with no memory of writing it is the only one who can tell you the paragraph you are
proudest of is the one that gets you closed.

## The theory — read this ONCE and the eight anti-patterns below stop needing to be memorised

Everything he does is downstream of one situation: **a maintainer buried under machine-generated
submissions that look right and aren't.** So he is not reviewing your code. **He is running a cheap
falsification test on a single question: did a mind make contact with reality here?**

Every rule below is an instance of that. Eight symptoms, one disease.

**1. Correct code does not save you.** #1904 was *"cleanly mergeable right now"* and was closed anyway; so
were #1907, #1910, #1109. Code correctness is not evidence that a mind was engaged — an agent produces
correct code by accident all the time. Stop optimising for "is my diff right." It's necessary and it is
nowhere near sufficient.

**2. Every sentence you write is a claim, and he RUNS it.** Not reads — runs. *"By inspection"* → he ran
it live 3× and the failure never happened (#1797). A named human reviewer → **he looked up the account**
(#1906, `msh01`, no such user). A ticked box → **he opened the file; it was empty** (#1925). *"No existing
PRs found"* → he searched, and found **your own**, byte-identical, closed 8 hours earlier (#1166).
→ *Never write a sentence you have not executed in the last hour. An unticked box with a reason has never
killed a PR. A false tick is sole-sufficient and fatal regardless of merit.*

**3. Depth is DEMANDED. Complexity is PUNISHED. They are different axes, and confusing them is the mistake
everyone makes — including this file, until 2026-07-14.** He closed #1797 for *too little* thought and #668
for *too much apparatus* (a JSON registry, a CLI manager, a GC daemon, LaunchAgents — where a config option
would do). He re-runs claims across three independent sessions; his own PRs run to +2,045 lines. There is no
economy-of-effort argument to make to this man.
→ *Deliberate as hard as the problem deserves; ship the smallest thing that solves it. **A big diff is
evidence you have not finished thinking.** Median merge here: 6 lines, 1 file.*

**4. The artifact of thought is NOT evidence of thought. Ship the residue, not the deliberation.** A PRD, an
ADR, a design doc — these are precisely what an agent generates by the yard. He cannot falsify them, so they
carry no weight: **0 of the 42 external merges linked one.** What *proves* thought is its checkable residue —
the commit you `git log -S`'d, his own closing comment quoted back at him, a command with its real output, an
eval with transcripts, the alternative you rejected and the reason. **Deliberate in private; submit only what
he can re-run.**

**5. The code is the way it is ON PURPOSE.** #1168 reverted a deliberate, named fix. #1903 and #1906 re-added
rows `e7ddc25` had pruned nine days earlier. #1882 deleted hardening that was added specifically to prevent
rationalization. **He git-blames every change and names the commit.**
→ *`git log -S'<the thing>'` before you touch it. If a commit removed it deliberately, you are not fixing a
bug — you are reversing a decision, and that requires evals, not opinions.*

**6. Before any of that: is it his problem, in his repo?** Venue is the single largest closure bucket (10 of
42) and it is decided *before your code is read*. Not-our-defect is 6 more — the bug was in Codex, OpenCode,
Gemini CLI, Claude Code. *Disable superpowers; if the symptom survives, it isn't his.*

**7. Engagement is per-PR, and it must be timestamped.** The count is not the crime — **measured: multi-PR
authors merge at the same per-PR rate as single-PR authors (3.7% vs 3.2%).** The *trawl* is the crime, and
its tell is that nobody ever engaged: both closed batches had **zero prior comments on every issue they
touched.** A comment on the issue that pre-dates your code is the one thing a trawler cannot retrofit, because
GitHub timestamps it.

**8. Silence is the baseline, not a verdict.** 84% of decided PRs are closed; 43% of closures carry no word
from him; 176 are open right now. **Quiet means untriaged.** Do not read it, do not chase it, do not let it
push you into volume.

> **If you remember one line:** *he is not asking whether your change is good. He is asking whether you are
> real. Answer that, in evidence he can re-run himself, and ship the smallest thing that works.*

## ⚖️ Calibration — read this BEFORE the anti-patterns, or you will over-correct

This file is a threat catalogue: it is ~46 words of *fatal / kill / closed* to ~7 of *this is fine*. That
ratio is a defect in the file, not a description of the danger. **Anxiety is not rigor.** It manufactures
findings, and a manufactured finding is indistinguishable from a real one until you check it — the same
demand-characteristics trap this file warns about when briefing a reviewer.

**The list of things that kill you regardless of a correct diff is SHORT, SPECIFIC, and entirely avoidable:**

1. **A sentence the repo state falsifies** — a reviewer whose account doesn't exist, a ticked box the file
   contradicts, "no prior PRs" when yours is right there.
2. **A claim you did not execute** — *"By inspection."*
3. **Wrong venue, or not his defect** — the largest bucket, decided before your code is read.
4. **Reverting a deliberate decision** without evals — he git-blames everything.
5. **The trawl** — a PR with no engagement anywhere that pre-dates it.

Clear those five and you are not going to be closed *on fault*. You may still not be merged — the base rate
is ~3.5% per PR against 176 open — but **that is queue depth, not judgement, and no amount of further
polishing touches it.**

**Measured, and NOT worth a minute of worry:**

| Fear | Reality |
|---|---|
| Targeting `main` instead of `dev` | 16 of 28 did. *"just housekeeping, not why we're closing"* (#956). |
| Merge conflicts | Excused when they're from his own history rewrite (#1937). |
| Being an agent | He triages with one and says so. Disclose it and move on. |
| Having several PRs open | **No penalty. 3.7% per-PR vs 3.2% for single-PR authors.** |
| Silence | 43% of closures carry no word from him. Quiet = untriaged. |
| An awkward sentence, a long body, imperfect prose | Nobody has ever been closed for this. |

**What over-correcting actually cost, in one session (2026-07-14) — every item produced BY this file's
threat-density, and every one wrong:**

- Called the upstream **"hostile"** and asked whether the maintainer was interrogating us. He has never sent
  us a single message. The fear invented an adversary.
- Panicked at a **176:1 process-to-output ratio** and nearly wrote it in here as doctrine. It measured the
  wrong thing entirely — he punishes complicated *solutions*, not deep thought.
- Nearly recommended **closing three good PRs to look tidy.** The data then showed the count carries no
  penalty at all.
- Reasoned confidently from a **"footer" signal that was fabricated** — inherited from our own report, which
  had string-matched a misquote.
- **Miscounted an eval twice with greps**, in opposite directions, while rushing to find something wrong.

**So: be rigorous about the five. Be relaxed about everything else.** The correct posture is a careful person
doing careful work, not a frightened one hunting for the next disqualifier. If you find yourself building a
case that you are doomed, you have stopped doing the work and started performing the anxiety — **go check the
base rate and then go review someone else's PR.**

## Anti-patterns — what actually gets you closed

**The triage is not a code reviewer. It is a groundedness detector.** They do not ask "is this code good."
They ask "did a mind touch this, or is it an artifact shaped like a contribution." That is why a *correct
diff does not save you* — four closures concede the code is right and close anyway (#1904, #1907, #1910,
#1109).

Evidence for every row: [`docs/reports/obra-triage-analysis.md`](../../../docs/reports/obra-triage-analysis.md)
(all 42 triage closures, hand-coded).

---

### ❌ 1. Assertion in place of execution

You reasoned about the code instead of running it.

> #1797 died on the words **"By inspection."** The triage then ran it live 3× and the failure never happened.
> #1781: they **ran the exact `npx` command at the exact version you cited.** The claim didn't hold.
> #1801: they **gave a fresh Sonnet agent your text across 3 independent sessions.** It did the right thing.

**Do instead:** run it, then quote the command and the output. "Reproduced on pristine `dev` @ `<sha>`:
`<command>` → `<output>`." Never write a sentence you have not executed in the last hour.

### ❌ 2. Amnesia about intent — you didn't ask why the code is like that

You "fixed" something that was deliberately done. **They git-blame every change and name the commit.**

> #1168 reverts `3f725ff` ("Strengthen brainstorming skill trigger") — a *deliberate, named fix*.
> #1882 deletes Red Flags added by `f6ee98a` **specifically to harden the skill against rationalization**.
> #1903/#1906 re-add rows `e7ddc25` pruned **nine days earlier** ("restate guidance modern agents already follow").

**Do instead:** `git log -S'<the thing you're changing>'` before you touch it. If a commit deliberately
removed it, you are not fixing a bug — you are reverting a decision, and you need evals to do that.

### ❌ 3. Fabricated attestation — a claim the repo state contradicts

**The single most fatal thing you can do.** They *check*.

> #1906: the PR named `msh01` as the human reviewer. **They looked it up. No such GitHub account exists.**
> #1109: the "independent verification" came from an account whose **only two actions in the entire repo**
> were confirming that issue and reviewing that PR — **posted at the exact same second.**
> #1925: **they opened the file you added. It was empty.** Both "human reviewed the complete diff" and
> "reviewed existing PRs" were ticked.
> #1166: **diffed by blob hash** against your own PR closed 8 hours earlier. Byte-identical — while your
> "Existing PRs" section claimed none were found.

**Do instead:** name a real human with a real account. Leave a box **unticked** rather than tick it falsely
— an unticked box with a reason has never killed a PR; a false tick is sole-sufficient. And **anything you
say on the thread is part of the submission**: if you promise something and then do otherwise, correct it
in public before they find it.

**And do the prior-art sweep the way that actually finds things — by the RULE'S OWN KEYWORDS, across CLOSED
history, not by issue number.** This is the countermeasure to the #1166 kill and it is not optional:

```bash
gh search prs --repo obra/superpowers --state closed "<the identifier your change is about>"
git log -S'<the thing you are adding>' upstream/dev      # was it deliberately REMOVED? (that's AP2)
```

Searching the open list and recent closures is what we did on #1982, and it missed **#362** — a closed PR
proposing our exact rule, sitting there with obra's own *"we'd welcome a fresh PR"* on it — while the box
saying we had reviewed all closed PRs was ticked. **The graveyard is where the prior art is, and it is also
where the free work is:** a close is usually staleness, not rejection, and the closing comment often carries
a standing invitation nobody has claimed.

### ❌ 4. Volume without engagement — a trawl, not a count

**The rule is NOT "one PR at a time." It is "every PR has a thread that pre-dates its code."**

There are only **three** batch incidents in the repo's history, and they are all machine sprays:

> 12 PRs in six hours on branches literally named **`pr-factory/issue-<N>-*`** (#627–640), templates blank.
> 10 PRs in **34 seconds** (#1901–#1910), with a "human reviewer" whose GitHub account doesn't exist.

**What it catches is an agent pointed at the issue list** — obra's own words. The tells are one PR per issue,
no prior engagement anywhere, blank templates, fabricated reviewers. **Not "several PRs."**

It is real, and it does close correct code: #1904 was *"cleanly mergeable right now"* and was closed for the
pattern alone. But the pattern is the trawl, not the number.

**Do instead — the per-PR test, not a quota:**

> **Is there a comment from you on that issue thread, posted BEFORE you wrote any code, where you laid out
> the problem and asked for a sanity check?**
>
> **Yes** → open it. **No** → don't. Go post it and wait.

That comment is the one thing a trawler cannot retrofit — GitHub timestamps it, and producing ten of them
across ten issues *is* the work they skipped. **Socialize-before-you-build is not etiquette. It is your
alibi.**

Several PRs each clearing that test is not a batch. Several that don't is a trawl — even if you spread them
over a week.

**Measured 2026-07-14 — the count carries NO penalty.** Per-PR merge rate since the rule went in
(2026-03-31), external authors only:

| | merged / PRs | per-PR rate |
|---|---|---|
| authors with exactly ONE PR | 8 / 248 | **3.2%** |
| authors with SEVERAL PRs | 7 / 189 | **3.7%** |

Statistically indistinguishable. *"Pick ONE issue"* is real guidance in his CLAUDE.md, and the section it
sits in is titled **"Bulk or spray-and-pray"** — the enforced thing is the spray. Both closed batches
(@tianma-if 10-in-34s, @stablegenius49 12-in-6h on `pr-factory/*` branches) had **zero prior comments on
every issue they touched.** That is the discriminator, and it is the one a trawler cannot fake.

**So do not close a good PR to look tidy.** But do not read this as licence either: the base rate is
**~3.5% per PR**, so several PRs mostly buys you several lottery tickets, and every one still has to clear
the gate on its own.

**Still true:** speed is the smell. If a human is impatient, socialize more issues; don't open more PRs
faster. And when several are ready, lead with the one cheapest for him to verify.

### ❌ 5. Misattributed causation — it's not their bug

Six closures. Superpowers is a pile of prompt files; the bug was in OpenCode, Codex, Gemini CLI,
Antigravity, or Claude Code itself. (#968, #1099, #1143, #1569, #1817, #1950)

**Do instead:** disable superpowers and check whether the symptom survives. If it does, it isn't theirs.

### ❌ 6. Venue blindness — right work, wrong repo

**The largest single bucket: 10 of 42.** Decided *before your code is read*. Third-party dependency or
domain-specific → standalone plugin, every time.

**Do instead:** ask "would this help someone on a completely different project?" before you write a line.
A good skill in the wrong repo is a wasted week.

### ❌ 7. Sounding like a bot

The repo's own word for it is **slop** — obra's `CLAUDE.md` says *"This pull request is slop that's made of lies."* The smell is what they act on.

- **Never narrate your own process.** "Four adversarial review rounds", "the PRD and design each went
  through a review pass" — nobody cares how your harness works. Say what is true about **their** code.
- **Never bold half the sentence.** Heavy `**bold**`, em-dash pileups, nested bullets = LLM house style.
- **Never structure a comment like a document.** A comment is a message to a person.
- **Never write long.** More than a few short paragraphs is showing off.
- **Never describe what gitban does.** The plugins row names it with a link. That is the entire disclosure.

**Do instead:** plain prose, one idea per sentence, short.

---

### ❌ 8. Noise — comments about YOU instead of about THEIR code

Anti-pattern 7 is *how* you write. This is *whether you should write at all*.

**The test, before every comment: does this serve HIM? If the subject is you, don't post it.**

**Everything below is noise. We posted all of it on 2026-07-13 and had to delete it:**

| What we posted | Why it's noise |
|---|---|
| *"Closing this myself, for a process reason rather than a technical one."* | He didn't ask. The timeline already shows the close. |
| *"Reopening this. I closed it earlier because…"* | Our indecision, narrated on his thread. |
| *"Amended: I dropped the Red Flags bullet."* | A changelog of our own second-guessing. The diff shows it. |
| *"Correction to this comment. I said I couldn't run the harness…"* | A correction to noise we created. |
| *"Correcting something I said on this thread…"* | A correction to a correction. |

Four of our five comments on #1982 were us **arguing with ourselves in public.** A maintainer opening that
thread sees a contributor in a spiral, not a contribution. **We deleted all of them; the PR body already
carried every fact that mattered.**

**The rules:**

- **Never narrate a decision you made about your own PR.** Closing, reopening, retargeting, amending — the
  timeline and the diff already say it. Adding prose is noise on top of a fact.
- **If you must correct something, EDIT the original comment. Do not stack a new one.** A thread of
  self-corrections reads as chaos, and each correction is itself more noise. Better still: don't post the
  thing that needs correcting.
- **Delete your own noise.** If a comment served your feelings rather than his review, remove it. The
  timeline keeps the events; you don't owe him the commentary.
- **A limitation of the change goes in the PR BODY, not a comment.** The body is the artifact he reads. The
  thread is for dialogue *with him* — questions you're asking, answers to what he said.
- **The one exception, and it is not optional:** a **false statement** must be corrected, publicly, before
  he finds it (anti-pattern 3). That is integrity, not noise. But note the cheaper path — *don't make
  claims you might have to retract.*

**What legitimately belongs on the thread:** the socialize-first intent comment (before you build), an
answer to something he asked, a genuine finding about *his* code, or a correction of a false claim. That's
the whole list.

## ✅ How to produce eval evidence — free, local, and it's THEIR method

**You can always run evals. We wrongly believed we couldn't for an entire session and it cost us real
content in a PR.**

`skills/writing-skills/SKILL.md` prescribes the method, and obra closed an RFC proposing anything else
(#1597) with *"largely covered already."* It is **RED/GREEN pressure testing**:

> *"If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing."*
> **RED** — agent violates the rule **without** the skill (baseline). **GREEN** — agent complies **with** it.

**The rig — costs nothing, runs on your subscription:**

```bash
# two trees, identical except your change
mkdir -p A B                       # tar will NOT create these for you
git archive upstream/dev  | tar -x -C A/
git archive <your-branch> | tar -x -C B/

# same prompt, fresh headless agent, N reps per arm, no hint what you're testing
claude -p "<a realistic task where the rule should fire>" --plugin-dir A/ --dangerously-skip-permissions
claude -p "<same prompt>"                                --plugin-dir B/ --dangerously-skip-permissions
```

Grade deterministically (grep for the behaviour), **3+ reps per arm** (agents are non-deterministic — obra
himself ran #1801 *"across 3 independent sessions"* before calling a claim false), and **paste the runs, not
a summary** — he asks for *"transcripts, not summaries"* (#1166).

**Quorum (`superpowers-evals`) is his internal lab, not the contributor bar.** It costs $7–15/run and needs
an API key, `gauntlet`, and `bun`. You do not need it. If you want it anyway: clone it, `bun install`,
`bun link` gauntlet, run with `--credential opus`.

### The tells that mark you as ungrounded

| Tell | Why it kills |
|---|---|
| "By inspection" / "this could cause" / "my review agent flagged" | No contact with reality. #1797. |
| A number a script can't confirm | They re-run every factual claim. |
| A named reviewer | **They look up the account.** |
| A ticked box | They open the file and check. #1925. |
| "No existing PRs found" | They search — including *your own*. #1166. |
| Several PRs, none socialized | The *trawl* is the charge, not the count. #1904. |

### Things that are NOT the reason — do not panic about these

- **`main` vs `dev`:** 16 of 28 PRs targeted `main`. **Never the reason.** *"just housekeeping, not why
  we're closing"* (#956).
- **Merge conflicts:** excused when it's obra's own history rewrite (#1937).
- **Being an AI:** he triages with one himself, and says so. Disclose it and move on.

### Where the free work is

**33 of 42 closures carry a retry invitation.** Several are confirmed-real bugs with a maintainer-written
spec and an explicit *"would be welcome"* — unclaimed, because the original submitter burned their PR:
**#1901** (TZ=UTC on archive creation) · **#1910** (worktree `.git`-is-a-file) · **#1902** (antigravity
test) · **#1939** (exec-form hook command). **Mine the graveyard before the issue tracker.**

### What lands

Of 131 merges, 89 are obra + arittr. Only **42 are genuinely external** — **median 6 lines, 1 file.**
Closed PRs: median 133 lines, 3 files. **Small and boring wins.**

### Silence is not rejection

**In 43% of closures obra never says a word** (304 of 714 — he closes without commenting; 114 carry *literally* zero comments from anyone). Closures arrive in **waves** after a triage run. Quiet
means *not yet triaged*. Don't read it as a verdict — and expect all your open PRs to be judged in one pass.

### A close is not terminal — and the footer tells you which verdict you got

Closures end: *"If you think this call is wrong, reply here — **Jesse reads these, and closures can be
revisited.**"* If they got a fact wrong, say so with evidence.

**The footer tells you NOTHING. It is boilerplate on every triage closure — 42 of 42, including the
integrity kills** (#1906's fabricated reviewer, #1925's empty file, #1166's byte-identical duplicate all
carry it). Verify before you believe otherwise:

```bash
gh api repos/obra/superpowers/issues/1906/comments --jq '.[].body' | grep -c "Jesse reads these"
```

*This file used to claim the footer appeared on only 16 of 42 and never on a fault-track closure — so its
absence meant "they think you cheated." That was invented signal, and it survived here because nobody ran
the grep. It is exactly the failure AP1 is about, committed by the document that teaches AP1.*

**So decide whether to argue on the evidence, not on the footer.** If they got a fact wrong, say so and
show the command. If they got it right, take the close.

## ⚖️ Right-size the pipeline to the change — FIRST, before you run any of it

**Measured on this fork, 2026-07-14: we shipped 20 added lines upstream and built 3,529 lines of apparatus
to do it — 176:1. Of that, 1,494 lines were a PRD + design doc + ADR deliberating a NINE-LINE prose change.**

That is the *exact* failure obra closes PRs for. He killed [#668](https://github.com/obra/superpowers/pull/668)
with *"a massive amount of complexity for what should be a straightforward configuration option"* — and that
author wasn't lazy, they were **taking the better long-term solution.** So are we. Our own lifecycle tenets
(*"no tech debt… take the better long-term solution… scalability is preferred"*) are a **rationalization
engine for gold-plating**, correct for a product we own and actively wrong for a small contribution to
someone else's repo.

**The median PR that actually merges here is 6 lines and 1 file.** Nobody writes a PRD for that.

| The change | What the fork pipeline should be |
|---|---|
| **A few lines of prose/config in an existing file** (most of what lands) | **No PRD. No ADR. No design doc. No deck.** Socialize on the issue, build it, gate it, open it. The deliberation belongs in the PR body's *Alternatives* section, which is where he'll actually read it. |
| **A new behaviour, or one that touches tuned skill content** | A design doc *if* you genuinely have alternatives to weigh — and it exists to **make the diff smaller**, not to justify it. Its output is the PR's Alternatives section. Skip the PRD. |
| **A new harness, or a real feature** | The full lifecycle earns its keep. This is rare. |

**The test:** *if the artifact will not change what you ship, do not write it.* #1982's design doc did earn
its keep — it ruled out naming `close_agent` and chose the 9-line option over a bigger one. But it did not
need 1,494 lines to do that, and the PRD and ADR above it changed nothing at all.

**And never link them to the PR.** Zero of the 42 external merges linked a PRD, ADR, design doc or showcase.
obra's template weighs *"content reasoned from documentation"* on a **lower** bar than work grounded in a real
session — attaching our planning docs volunteers us into his low-trust bucket while advertising a
process-to-output ratio he closes people for. Depth is shown in *his* currency: `git log -S` on the code you're
touching, a command with its output, an eval with transcripts. Not in our documents.

## ⚖️ Deep thought, simple solution — right-size the SHIPPED THING, never the thinking

**He does not punish thought. He punishes shallow work and complicated solutions.**

The evidence runs the opposite way to the intuition. [#1797](https://github.com/obra/superpowers/pull/1797)
died on the words **"By inspection"** — closed for *not thinking hard enough*. He re-ran a contributor's
claim *"across 3 independent sessions"* before calling it false (#1801). He asks for **"transcripts, not
summaries"** (#1166), and his template demands *"genuine understanding of the problem, investigation of
prior attempts."* His own PRs run to +2,045 lines. There is no economy-of-effort here to appeal to.

What he closed [#668](https://github.com/obra/superpowers/pull/668) for was *"a massive amount of complexity
for what should be a straightforward configuration option"* — a JSON registry, a CLI manager, a GC daemon,
post-merge hooks and LaunchAgents. **That is a verdict on the artifact, not on the deliberation behind it.**
And note *why* it happened: that author wasn't lazy, they were **taking the better long-term solution** —
which is our own lifecycle tenet, and it is a rationalization engine for gold-plating **the deliverable.**
Point it at the deliverable and it kills you here. Point it at the thinking and it's exactly right.

**So: deliberate as hard as the problem deserves, then ship the smallest thing that solves it.** The median
PR that merges here is **6 lines, 1 file** — not because he wants shallow work, but because a deeply
understood problem usually has a small answer. A big diff is evidence you have not finished thinking.

**The test for any planning artifact: does it make the diff SMALLER?** If yes, it earned its keep however
long it is. If it only justifies a diff you had already decided on, it is decoration. (#1982's design doc
passes: it ruled out naming `close_agent` in the bodies and chose the 9-line option over a larger one. The
PRD above it changed nothing about what shipped.)

**Two things follow, and only two:**

1. **Never let the artifacts inflate the diff.** They exist to shrink it.
2. **Don't link them to the PR.** Not because thinking is bad — because they are not the evidence he checks.
   **Zero of the 42 external merges linked a PRD, ADR, design doc or showcase.** Depth is demonstrated in
   *his* currency and nowhere else: `git log -S` on the code you're touching, a command with its real output,
   an eval with transcripts, his own closing comment quoted back. Put the deliberation's *conclusions* in the
   PR body's **Alternatives** section — that is where he reads them, and it is the same argument without the
   process narration (AP7).

## The sequence — how a good contributor lands a change

The *order* matters as much as the work. At a heavily-rejecting, anti-slop upstream (see CREDIBILITY's Baseline) you want to appear as a
person **thinking out loud and checking in**, then deliver a **clean, pre-discussed PR** — never a cold
monolith dropped from nowhere. So you socialize the **plan** before you build, and the fork publishes in
**two waves** (planning artifacts early, code + decks after). Sections below detail each step.

0. **Read the room.** Read the whole upstream issue thread + any linked PRs. What does the maintainer want
   / not want? Did someone propose an approach? Is anyone already working it? Calibrate tone; don't
   duplicate or step on toes.
1. **Plan locally — sized to the change.** A few lines of prose or config (i.e. most of what merges here):
   just think it through; skip the lifecycle entirely. Something genuinely load-bearing, or touching tuned
   skill content: a design doc, *if* weighing the alternatives will shrink the diff. A new harness or a real
   feature: the full PRD → design doc → ADR earns its keep. **The test is whether the artifact changes what
   you ship. If it won't, don't write it.**
2. **Signal intent on the upstream issue** (the human posts — see *Issue etiquette*). A short, human comment:
   your concrete understanding of the problem, your intended approach, engagement with the thread, and the
   fork planning artifacts offered as *optional* reading — then ask for a sanity check **before** you build.
   *Skip this stage only for a tiny, obvious fix the maintainer has already blessed.*
3. **Read the signal** — 👍 / "sounds good" / a redirect / reasonable silence for low-risk → proceed; adjust
   the plan if they steer you. This gate is the point: it stops you building the wrong or unwelcome thing.
4. **Build** — run the gitban sprint. Then publish the **full** fork showcase (code artifacts + decks) on
   `showcase/<slug>` (open the browsable fork PR) and finish the mirror-issue narrative.
5. **Derive the clean upstream branch** — `fix/<slug>` off `upstream/dev`, `git checkout <work-branch> --
   <code files>`, commit clean; verify `git diff --stat upstream/dev` is exactly the change.
6. **Open the upstream code PR** — push `fix/<slug>`, open **`muunkky:fix/<slug>` → `obra:dev`
   ready-for-review, NOT a draft.** (`gitban-pr` defaults to draft for internal work; upstream is the
   exception — the triage assesses mergeability, and a draft reads as unfinished. Pass `--draft=false`.)
   Reference the earlier discussion ("as discussed above"); fill obra's template completely; disclosure
   table; **a human reviews the full diff before it goes out.** **Do NOT link the fork showcase or any
   planning doc** — 0 of the 42 external merges did, he cannot re-run them, and it reads as process-flashing
   (AP7). Put the deliberation's *conclusions* in the template's **Alternatives** section instead; that is
   the same argument in a form he can check.
7. **Shepherd it** — respond to review judiciously, in the human's voice.
8. **Record it** (see *Keep a record*) — append the interaction to the contributions log and mirror its refs
   into the matching roadmap node. A landed PR, a deferral, or just a comment all count.

⚠️ **Re-check the room right before you publish — the thread moves while you build.** Stage 0 is not a
one-time check. On #1957 a competing PR (**#1964**) appeared *mid-build* and landed the same fix first; we
only caught it by re-running Stage 0 before pushing. So immediately before you publish the showcase or open
the PR, re-scan the issue + open PRs. If someone got there first, **switch to the additive move** (offer
your extras to *their* PR — see *Issue etiquette* → "already built"). It works: both our additions were
folded into #1964, and our `dev`-branch flag fixed its base — a better outcome than a rival PR would have got.

**Two PRs + one issue:** the fork showcase PR (browsable gitban story), the upstream code PR (the clean
contribution), and the fork mirror issue (the narrative). **Cross-link all three** ↔ the upstream issue.

## The three places

| Place | Remote | Role |
|---|---|---|
| **local** working tree | — | where work happens; holds the code, the gitban artifacts, and `.claude/` |
| **fork** `muunkky/superpowers` | `origin` (push OK) | your working base + public showcase; carries `.claude/` tooling and per-contribution artifacts |
| **upstream** `obra/superpowers` | `upstream` (**fetch only** — push URL DISABLED) | the canonical project; receives only clean, code-only PRs |

- Confirm remotes before contributing: `origin → muunkky/superpowers`, `upstream → obra/superpowers`
  with its **push URL set to `DISABLED`** so a stray `git push upstream` can never hit the canonical
  repo. Never re-enable it.
- The fork's `main` tracks **`origin/main`** — it is OURS. It carries `.claude/` and has diverged from
  `upstream/dev` permanently and on purpose (see *Keeping the fork in sync*). You build every contribution
  branch off `upstream/dev` directly; `main` is never fast-forwarded onto it.

## New-machine / fork setup — FIRST COMMAND ON EVERY FRESH CLONE

```bash
.claude/skills/contributing/fork-setup.sh    # idempotent; verifies, doesn't just assert
```

Two things do **not** travel through git, so a fresh clone is **silently unsafe until you run this**:

1. **`.git/info/exclude`** — the local ignore that makes gitban's artifacts invisible to git (the
   guardrail below). Never synced. Without it, `git add -A` on a contribution branch stages
   `.gitban/` and `docs/prds/` and they ship in the upstream PR.
2. **The `upstream` remote** and its **disabled push URL**. Without it, nothing stops
   `git push upstream` from reaching the canonical repo.

The script recreates both and then *proves* it: it writes a probe file under `.gitban/` and checks
`git check-ignore` actually hides it. It was prose in a code block here until 2026-07-14 and nobody
had ever run it — which meant the guardrail the whole skill rests on did not exist on disk.

`.claude/` itself is tracked on the fork (force-added — the tracked root `.gitignore` ignores it),
so your skills, `.claude/CLAUDE.md`, and this playbook sync across machines automatically. It never
reaches upstream because upstream branches are *derived clean* (below), not pushed from here.

## The guardrail — why the split is automatic, not manual

gitban's lifecycle artifacts (PRDs, ADRs, design docs, decks, cards, roadmap, reports) are kept out
of git via **`.git/info/exclude`** (recreated by the setup script). It lives there and **not** in the
tracked `.gitignore` on purpose — editing the tracked `.gitignore` would itself be an upstream diff.

Because these are invisible to git, the code you commit is clean *by construction* — you can't
accidentally commit an artifact, because git can't see it. The only deliberate act is a `git add -f`
when you publish the showcase. **Do not "fix" this by moving the entries into the tracked
`.gitignore`** — that leaks the guardrail into an upstream diff, the exact thing it prevents.

### What goes where

| Content | In git by default? | Upstream PR | Fork |
|---|---|---|---|
| The actual code / doc change | tracked | ✅ yes | ✅ (it's the code) |
| PRD / design / ADR / decks / cards / roadmap | excluded (invisible) | ❌ never | ✅ force-added to `showcase/<slug>` |
| `.claude/` tooling (skills, CLAUDE.md) | ignored by root `.gitignore` | ❌ never | ✅ force-added, tracked for multi-machine sync |

## Keeping the fork in sync with upstream

`obra`'s `dev` keeps moving. Re-fetch **before starting each contribution** so your base is current.

**You do not "sync main". `main` is OURS and it has diverged permanently, on purpose** — it carries
`.claude/` and the fork's tooling, which upstream will never have. It is dozens of commits ahead of
`upstream/dev` and `git merge --ff-only upstream/dev` will refuse forever. That is the architecture
working, **not** a sign you broke something.

**`upstream/dev` is the base you build on; you never merge it into `main`.** All you need is:

```bash
git fetch upstream        # that's it — upstream/dev is now current
```

Every contribution branch is cut *fresh off `upstream/dev`* (see *Opening the upstream PR*), so it is
current by construction and carries none of the fork's tooling. `main` never touches upstream and never
needs to.

Only if you want the fork's `main` to also carry obra's latest code (for local testing against a current
tree): `git merge upstream/dev` — an ordinary merge, never `--ff-only`, never a force-push.

## The disclosure — one line, identical every time

obra requires model + harness + plugins. Naming the plugin is mandatory — so **gitban gets named, with its
link**. That is legitimate and it is the visibility we want. What is NOT allowed is *narrating what gitban
does*. Use exactly this in every comment, varying only the short grounding clause:

> Disclosure: agent-assisted — \<model + exact ID\>, \<harness + version\>.
> Plugins: \<every enabled plugin; name gitban with its link, muunkky.github.io/gitban-site\>.
> Grounded in \<one short clause: what you actually ran or read\>.

**EVERY field is a fact about THIS machine and THIS session. Read them; never recall them, and never
copy them out of this file** — the angle brackets are deliberate, and a template that ships its own
answers gets recited instead of read. That is not a hypothetical: this template used to hardcode the
model, the version and the plugin list, and it produced four PRs that named one plugin out of four and
a harness version that had already moved.

```bash
claude --version    # the harness version, right now
python3 -c "import json;print(*json.load(open('$HOME/.claude/settings.json'))['enabledPlugins'],sep='\n')"
                    # EVERY enabled plugin, not just gitban. (Not jq — it is not installed here.)
```

The model is whatever you actually are, with its **exact ID** — a `[1m]` suffix is part of the ID.
**Enumerate, don't curate:** a plugin that played no part in the work is still *installed*. And never
close the list with a flourish like "no others" or "nothing else" — that is a checkable assertion, and
it is the one shape of sentence that is fatal on its own.

His bar is *"all installed plugins"*, and *"contributions that hide their authoring environment will be
closed."* **"gitban. No others." is a checkable false statement** — we shipped exactly that on #1984 while
three more plugins were enabled, and shipped a stale `2.1.207` on all four PRs after the CLI moved to
`2.1.208`. Both are AP3, the sole-sufficient kill. A plugin that played no part in the work is still an
*installed* plugin: **enumerate, don't curate.** `preflight.sh` now diffs your disclosure against
`settings.json` and against `claude --version` — let it, rather than trusting this paragraph.

**The link stays. The lifecycle narration never appears.** "gitban plugin (muunkky.github.io/gitban-site)"
is a disclosure field with a URL — fine, and someone curious can click it. "gitban, driving the roadmap →
PRD → design → ADR → sprint lifecycle, with an adversarial reviewer at each gate" is an advertisement — it
goes nowhere, ever.

Never expand it. **Never vary the format between comments** — an inconsistent disclosure looks improvised,
because it was. (In a **PR body** obra's template demands the fields as a table; fill that table, name gitban
with the link in the plugins row, and add nothing else.)

## Issue etiquette — how to appear as a good contributor

We run the *process* on the fork, not in obra's face — that's how we sidestep the anti-slop concern. The
upstream thread should read as a thoughtful person, never an AI dump.

- **Mirror the upstream issue as a fork issue.** Post the full gitban narrative there — PRD → design doc →
  ADR as comments — so the story is visible and ours to shape.
- **Every upstream comment clears the gate before it is posted** — scratch file → `preflight.sh --text` →
  isolated verifier → post. This is the single surface where AI-shaped text does the most damage, so the
  control has to be one that actually runs. **Do not write "the human approves each comment word-for-word"
  and then post without them** — the human is usually away, and a control you skip every time is worse than
  none. The gate above is the control. **The one thing that IS the human's: they review the complete diff
  before a PR goes out.** obra requires it, and it is the one claim we ever tick a box for.
- **The intent comment (Stage 2) leads with understanding, then offers help, then asks.** Keep it to a few
  sentences. A shape that works:

  > "Had a look at this — the core of it is that *&lt;one concrete, specific technical sentence that proves
  > you actually understand the problem&gt;*. I'm thinking of *&lt;approach in a line&gt;*. I wrote up a quick
  > … Would love a sanity check on the approach before I build it.

  **The comment carries the understanding; a link never will.** The one sentence that proves you understand
  the problem does all the work — he can check that against his own code. If planning docs exist on the fork,
  mention them in a trailing clause *at most* ("there's a writeup on my fork if it's useful"), and never as
  the substance. He is not going to read them, and asking him to is asking for his scarcest resource."

  Engage what's already on the thread: *"Building on @so-and-so's suggestion, I'll give this a try…"* or
  *"I had a slightly different angle — mind taking a look?"*

- **If the work is already built** (you got ahead of the socialize-first order — sometimes fine: a demo, or
  a fix you needed anyway), still lead with the *idea*, not the finished PR. Post the intent comment above,
  then offer the solution **separately and lightly** — a follow-up comment or a trailing line:

  > *"I actually went ahead and built a version already — it's on my fork if it's helpful to have a look
  > \[link]. Happy to rework it to whatever approach you'd prefer."*

  Offering it as *optional and adjustable* keeps you from looking like you're dropping a finished thing and
  demanding it be merged.

- **The links are "if it's helpful," never homework.** You're asking *"am I aiming at the right thing?"*,
  not *"please review my documents."* The fork carries the depth; the comment carries the intent.
- **Never dump generated PRDs/ADRs or long AI analysis inline** — that's exactly what the fork links exist
  to avoid.
- **Substantive comments carry the disclosure too.** obra's rule is "every PR **and issue** must disclose."
  Use the **exact one-liner from *The disclosure* above** — never improvise a variant, never describe what
  gitban does. Skip it only for a trivial one-liner comment.
- **Cross-link both ways:** fork issue / showcase ↔ upstream PR ↔ upstream issue.

## Opening the upstream PR

> **⛔ The body is written by the `gitban-pr` skill. Never hand-roll it.** Its `SKILL.local.md` overlay owns
> the template, the disclosure table, and the no-narration rules.

**This** skill owns one thing — derive a clean branch. Never push your working branch:

```bash
git fetch upstream
git checkout -b fix/<slug> upstream/dev
git checkout <work-branch> -- <the changed code files>   # only the real files
git commit                                               # no attribution footer
git diff --stat upstream/dev                             # exactly the change, nothing else
```

**The human reviews the complete diff BEFORE it goes out — that is the one box we ever tick — and then you
open it ready-for-review, not as a draft** (`--draft=false`; `gitban-pr` defaults to draft for internal work
and upstream is the exception). The triage assesses mergeability, and a draft reads as unfinished. Do not
open it early and mark it ready later: the human review is a gate *before* the PR exists, not a stage of it.

## Building the fork showcase (public, one branch per contribution)

The showcase is where the gitban story is visible — public on the fork, never sent upstream. One
`showcase/<slug>` branch per contribution:

```bash
git checkout -b showcase/<slug> origin/main
git add -f docs/prds docs/adr docs/designs docs/decks .gitban/cards .gitban/roadmap
git commit -m "showcase: <slug> — gitban lifecycle artifacts + decks"
git push origin showcase/<slug>
```

Cross-link: the showcase → the upstream PR + the issue; the upstream PR → the showcase.

## "Check for comments" — sweep every thread we've touched

When the user says **"check for comments"**, *"anything new upstream?"*, *"did obra reply?"*, *"what's the
state of our PRs?"* — or at the start of any upstream work — run:

```bash
.claude/skills/contributing/check-upstream.sh          # new activity since the last sweep
.claude/skills/contributing/check-upstream.sh --all    # every thread we've touched + its state
```

It flags maintainer comments with `⚑ MAINTAINER` and surfaces **PR reviews** separately, because a review
is not an issue comment and is trivially missed.

**The thread list is DERIVED from GitHub, never hand-maintained.** A manifest we had to remember to update
would drift, and the sweep would then report *"nothing new"* while silently skipping a thread — the same
class of bug as a stale overlay. GitHub already knows every issue and PR we've authored or commented on;
that *is* the manifest. The only state kept is a last-checked timestamp.

> **This bit is load-bearing:** `gh search issues` **does not return pull requests.** The first version of
> this script queried only issues, reported 4 threads, and silently omitted all four of our own PRs *and*
> every PR we'd reviewed. It now queries `issues` **and** `prs`, for both `--author` and `--commenter`. If
> you change the query, verify the count against `--all` — a sweep that quietly misses threads is worse
> than no sweep, because you'll trust it.

**Then triage each hit — reply / record / ignore:**

- **A maintainer response** → highest priority. Answer it, and log it in `CREDIBILITY.md` (it's our
  scarcest signal, positive or negative).
- **Someone acted on our review** → log it. *This is the play that's working — see the tally in `CREDIBILITY.md`, which is the only place it is kept. Our additive reviews
  have been adopted.* (Its first run found one we'd missed entirely — @vladsoltan had adopted all three of
  our points on #1976 and we didn't know.)
- **A close or criticism** → log it, with their operative sentence quoted.
- **Routine chatter** → don't log it. The ledger is signals, not a log.

## The credibility ledger — read it first, update it last

**[`CREDIBILITY.md`](CREDIBILITY.md) (in this skill's directory) is the scoreboard for this entire
strategy.** Read it **before** you engage upstream — it tells you what has actually worked, who has
responded to us, and what our standing is. Update it **after** every upstream interaction.

It exists because the bet we are making is falsifiable: *being visibly the best contributor in the room
compounds — people cite you, take your review notes, and eventually the maintainer reads your PR with a
prior that it's worth his time.* That either happens or it doesn't, and the only way to know is to write
down what other people actually did.

It's an **index, not an archive** — short rows, link out to GitHub. **Log a row only when someone else did
something because of what we did** (a citation, an endorsement, our code taken, a defect acted on, a close)
**or when we did something we shouldn't repeat.** Never log volume — PRs opened, docs written, lines
changed are inputs, not signals, and a ledger full of them is a mood board.

**Negatives go first, and when we're rejected or criticized, quote the one operative sentence.** Not for
fidelity — for us. We soften bad news about ourselves without noticing: *"he had concerns about scope"* and
*"this pull request is slop that's made of lies"* are the same event after a paraphrase.

**Keep the baseline in view.** Silence at a repo with ~178 open PRs and ~3% movement is *data about the
repo*, not a verdict on us. You can only tell the difference if the baseline is written down.

## Keep a record — the log + the roadmap

Every upstream interaction is recorded in **two** places, so nothing is lost and the roadmap stays the map:

1. **The contributions log** — `.gitban/contributions-log.md` (preserved gitban project data, sitting
   alongside the roadmap it cross-references; force-add it to the fork with the other `.gitban/` data).
   Append one entry per issue/PR you engage: the upstream issue, the roadmap node path, what you built, the fork showcase
   link, the upstream move (PR / comment / deferred), the links, and the current status. It's the running
   history of how we've shown up upstream — **read it before engaging a new issue** so you don't repeat
   yourself or contradict a past call.
2. **The matching roadmap node** — `upsert_roadmap` the node for that area (e.g.
   `m1/s3/brainstorming/companion-security-hardening`) with the interaction refs: the upstream issue + PR +
   your comment links, the fork showcase branch, and the outcome (e.g. *"deferred to competing PR
   obra#1964"*). Move the node's `status` to `verifying` once our build is done and the ball is in the
   maintainer's court. This keeps the roadmap the single source of truth for where each upstream area stands.

Do both as the final step of every contribution.

## Never

- **Edit the tracked root `CLAUDE.md`** — it's obra's; edits pollute the fork and cause merge conflicts.
  Put *our* instructions in `.claude/CLAUDE.md` (tracked on the fork, ignored upstream).
- **Push to `upstream`** — fetch-only; push URL is DISABLED. Keep it that way.
- **Include any gitban artifact or `.claude/` file** in the upstream PR (derive the branch clean).
- **Move the `.git/info/exclude` entries into the tracked `.gitignore`** — leaks the guardrail upstream.
- **Add a `Co-Authored-By`/"Generated with" footer** to commits or the PR — vanity attribution is banned.
- **Dump generated lifecycle docs into obra's upstream issue threads** — keep the narrative on the fork.
