---
name: contributing
description: >
  This project's playbook for moving changes from the local working tree → the
  muunkky/superpowers fork → the obra/superpowers upstream. Use this skill WHENEVER you are
  about to open or prepare a pull request upstream, push a branch, sync the fork with upstream,
  decide what belongs on the fork versus upstream, build or update a fork "showcase", set up the
  repo on a new machine, comment on an upstream issue, or when the user says things like "push
  this up", "open the PR", "contribute this", "send it to obra", "showcase the process", "sync
  the fork", or asks how the local→fork→upstream split works. It captures the hard-won rules:
  derive a clean, code-only branch targeted at `dev`; keep every gitban lifecycle artifact
  (PRDs, ADRs, design docs, decks, cards, roadmap) and all `.claude/` tooling on the fork only;
  include the mandatory authoring-environment disclosure (which is NOT the banned vanity kind);
  mirror the upstream issue on the fork and stay judicious on upstream threads; never push to
  upstream directly; and never touch the pristine tracked root CLAUDE.md.
---

# Contributing — local → fork → upstream

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

**So: always run the fork pipeline; then decide the upstream move — up to and including "don't."** Running
the fork first is what gives you the artifacts to reference and lets you make the upstream call from strength
— or walk away cleanly from a duplicate. (Real case: #1957 — we published the full fork showcase, then the
right upstream move turned out to be a light comment, not a PR, because #1964 landed the same fix first.)

## The sequence — how a good contributor lands a change

The *order* matters as much as the work. At a 94%-rejection, anti-slop upstream you want to appear as a
person **thinking out loud and checking in**, then deliver a **clean, pre-discussed PR** — never a cold
monolith dropped from nowhere. So you socialize the **plan** before you build, and the fork publishes in
**two waves** (planning artifacts early, code + decks after). Sections below detail each step.

0. **Read the room.** Read the whole upstream issue thread + any linked PRs. What does the maintainer want
   / not want? Did someone propose an approach? Is anyone already working it? Calibrate tone; don't
   duplicate or step on toes.
1. **Plan locally** — PRD → design doc → ADR (gitban's Plan phase). Publish just these *planning* artifacts
   to the fork (the mirror issue, and/or a first `showcase/<slug>` push) so they're linkable.
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
6. **Open the upstream code PR** — push `fix/<slug>`, open **`muunkky:fix/<slug>` → `obra:dev`** as a
   **draft**; reference the earlier discussion ("as discussed above"); fill obra's template completely;
   disclosure table; link the fork showcase; a human reviews the full diff before it goes out.
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
- The fork's default branch (`main`) tracks **`upstream/dev`** — that's obra's active integration
  branch and where contributions land. (Flip to `upstream/main` only if you deliberately want the
  released base; state which you chose.)

## New-machine / fork setup (do this on every fresh clone)

Two things do **not** travel through git and must be re-established per machine:

1. **`.git/info/exclude`** — a local, uncommitted ignore (see the guardrail below). Never synced.
2. **The `upstream` remote** and its disabled push URL.

Keep a tracked-on-the-fork setup script (e.g. `scripts/fork-setup.sh`, force-added to the fork,
**never** sent upstream) that recreates both, so a new clone is one command away from correct:

```bash
# scripts/fork-setup.sh  (lives on the fork; run once per clone)
git remote add upstream https://github.com/obra/superpowers.git 2>/dev/null || true
git remote set-url --push upstream DISABLED
cat >> .git/info/exclude <<'EOF'
.gitban/
docs/prds/
docs/adr/
docs/designs/
docs/decks/
docs/reports/
CONTRIBUTING-gitban.md
EOF
```

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

`obra`'s `dev` (and `main`) keep moving. Re-sync **at least before starting each contribution** so
your base is current and your PR merges cleanly:

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/dev      # or upstream/main, whichever main tracks
git push origin main
```

If `--ff-only` refuses, your fork's main has diverged (usually because tooling/artifacts were
committed to it) — rebase or reconcile deliberately rather than force-merging.

## Write like a person — the #1 way this fails

**The maintainer's trust is the scarce resource, and AI-sounding text burns it faster than a bad patch.**
A comment that reads as machine-generated gets the contribution closed on sight regardless of merit. This
upstream closes "slop" as a matter of policy; the *smell* is what they act on, not the substance.

**Never do these — each is a loud, unmistakable AI tell:**

- **Never narrate your own process.** Nobody cares that "the design went through four adversarial review
  rounds," that "the PRD and design each went through an adversarial review pass," or that "it was that
  review that killed my option (a)." This is meta about *our* harness. It is self-indulgent, it is
  transparently machine-written, and it is the single most annoying thing you can put in someone else's
  thread. **Say what is true about THEIR code. Never about your workflow.** If a template section
  explicitly asks how you tested, answer it in one plain sentence about the *code* — not a tour of the
  lifecycle.
- **Never bold half the sentence.** Heavy `**bold**`, em-dash pileups, and nested bullet hierarchies are
  LLM house style, not human writing. Plain prose. One idea per sentence.
- **Never structure a comment like a document** — headers, tables, decision records — unless the content
  truly demands it. A comment is a message to a person, not a deliverable.
- **Never write long.** More than a few short paragraphs means you are showing off.
- **Never say "Produced with gitban … driving the roadmap → PRD → design → ADR → sprint lifecycle."**
  That is advertising, not disclosure. It goes nowhere, ever.

## The disclosure — one line, identical every time

obra requires model + harness + plugins. Naming the plugin is mandatory — so **gitban gets named, with its
link**. That is legitimate and it is the visibility we want. What is NOT allowed is *narrating what gitban
does*. Use exactly this in every comment, varying only the short grounding clause:

> Disclosure: agent-assisted — Claude Opus 4.8 (`claude-opus-4-8`), Claude Code 2.1.207, gitban plugin
> (muunkky.github.io/gitban-site). Grounded in \<one short clause: what you actually ran or read\>.

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
- **Upstream comments are the human's.** The agent may *draft* them, but the human posts / approves the
  wording word-for-word, in their own voice. This is the single surface where AI-shaped text does the most
  damage — the maintainer's trust is the scarce resource.
- **The intent comment (Stage 2) leads with understanding, then offers help, then asks.** Keep it to a few
  sentences. A shape that works:

  > "Had a look at this — the core of it is that *&lt;one concrete, specific technical sentence that proves
  > you actually understand the problem&gt;*. I'm thinking of *&lt;approach in a line&gt;*. I wrote up a quick
  > PRD + design on my fork to make sure I've got the problem right \[link] — kept off here to avoid cruft.
  > I keep the ADRs on my fork too, so you can look at those as well if it's helpful. Would love a sanity
  > check on the approach before I build it."

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
- **Substantive comments carry the disclosure too.** obra's rule is "every PR **and issue** must disclose,"
  so any comment that *offers or describes agent-produced work* ends with a compact one-liner — e.g.
  *"Disclosure (per contribution rules): produced with an autonomous development harness — gitban — on
  Claude Code / Claude Opus; reasoned from the issue + code inspection."* Skip it only for a trivial one-liner.
- **Cross-link both ways:** fork issue / showcase ↔ upstream PR ↔ upstream issue.

## Opening the upstream PR (obra/superpowers)

`obra/superpowers` has a ~94% rejection rate and closes slop on sight. Full rules: the **tracked root
`CLAUDE.md`** + `.github/PULL_REQUEST_TEMPLATE.md`. The load-bearing ones:

1. **Derive a fresh, clean branch — never push your working/sprint branch** (it may carry force-added
   artifacts, deck commits, or messy history). Slice only the code onto a clean branch off the right base:
   ```bash
   git fetch upstream
   git checkout -b fix/<slug> upstream/dev
   git checkout <work-branch> -- <the changed code files>   # only the real files
   git commit                                               # clean message, no attribution footer
   git diff --stat upstream/dev                             # verify: exactly the change, nothing else
   ```
2. **Target `dev`, never `main`.**
3. **One problem per PR.** No bundled/unrelated changes, no scope creep, no speculative fixes. Solve a
   real, reproducible problem — ideally a filed issue you can point to.
4. **Search open AND closed PRs first**; cite what you found and why yours differs.
5. **Complete the PR template** — every section, real answers, no placeholders.
6. **A human reviews the complete diff** before submission.
7. **No new third-party dependencies**; no reformat/"compliance" edits to tuned skill content without eval evidence.
8. **Include the authoring disclosure** (see next section) — mandatory.
9. **Link the fork showcase** once (transparency + it advertises gitban), but lead with the fix and the
   problem, not the machinery.

Open it as a **draft** first; show the human the full diff + PR body before it goes out.

## The PR-body disclosure — fill obra's table, add nothing

Two rules meet here and look like they conflict. They don't.

**Vanity attribution — banned everywhere.** `Co-Authored-By: Claude <noreply@anthropic.com>`, or
`🤖 Generated with [Claude Code](…)`. Strip it from commits and PR text.

**Obra's required disclosure — fill his template's table. That is the whole disclosure.** He names the
fields; answer them as fact:

| Field | Value (re-verify each session) |
|---|---|
| Your model + version | Claude Opus 4.8 (`claude-opus-4-8`), 1M context |
| Harness + version | Claude Code `<version>` (`claude --version`) |
| All plugins installed | gitban (muunkky.github.io/gitban-site); enumerate any others loaded this session |
| Human partner who reviewed this diff | the human who actually read the diff |

**Do NOT add a prose disclosure paragraph above or below that table.** No "produced with an autonomous
development harness", no "driving the full roadmap → PRD → design → ADR → sprint lifecycle". The plugins
row already names gitban and links it — that is the disclosure, and it is all the visibility gitban gets.
A sentence describing what gitban *does* is an advertisement, and it is the loudest AI tell in the document.

See *The disclosure* above for the comment form (one line, identical every time).

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
