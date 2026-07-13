# Project overlay — muunkky/superpowers fork

## Writing an UPSTREAM PR to obra/superpowers — override your defaults

When the PR targets the `obra/superpowers` **upstream** (a fork contribution, not an internal repo),
several of your defaults are wrong for it. Override them:

- **Target `dev`, not `main`.** obra takes contributions on `dev`; PRs to `main` are asked to retarget.
- **Fill obra's `.github/PULL_REQUEST_TEMPLATE.md` completely — do NOT impose your own PR structure.**
  obra closes PRs that skip template sections or fill them with placeholders. Read the template and
  answer every section with real, specific content. Your usual "size the arc/sections to the diff"
  instinct is overridden here: *the template is the shape.*
- **The diff is code-only.** The PR is written from the derived clean branch (only the changed source
  files). If asked to "add the decks / PRD / ADR so reviewers see our process," **refuse** — those are
  fork-showcase artifacts and obra reads them as slop. Link the fork showcase in the body instead.
- **One problem, described as a problem.** Frame the PR around the real, reproducible problem (ideally a
  filed issue), not a changelog of what you touched. No bundling, no scope creep, no speculative fixes.
- **Search open AND closed PRs first** and fill the template's existing-PRs section: what you found and
  why yours differs — especially why a previously *closed* attempt should succeed where it didn't.
- **Link the fork showcase once** (transparency; also advertises gitban) — but lead with the fix.
- Open as a **draft**; a human reviews the complete diff before it is submitted.

The rest of the local→fork→upstream split (clean-branch derivation, the `.git/info/exclude` guardrail,
building the showcase branch, issue etiquette) lives in the **`contributing`** skill — consult it.

## Authoring disclosure vs. vanity attribution (read before writing any PR body)

Two rules meet in a PR and *look* like they conflict; they don't. Getting the distinction right is
what keeps a PR both clean and acceptable to a strict upstream:

- **Vanity attribution — NEVER add it** (to commits or PR text). This is the auto-injected footer:
  `Co-Authored-By: Claude <noreply@anthropic.com>`, `🤖 Generated with [Claude Code](…)`, or any
  "generated with / built by <vendor>" branding. It turns the author's work into a vendor ad and is
  banned everywhere. If the harness injects it, strip it.

- **Required factual disclosure — INCLUDE it in the PR body when the target project requires it.**
  `obra/superpowers`, for example, mandates that every PR disclose the **model, harness + version, and
  installed plugins** (or state it was hand-written); hiding it — or an *incomplete* one-liner that omits
  the model — gets the PR closed. That's a compliance form the *recipient* demands, answered as fact.

  **Fill obra's table. Nothing else. No prose disclosure paragraph above it.** gitban is named in the
  plugins row *with its link* — that is the disclosure, and it is all the visibility it gets:

  | Field | Value (re-verify each session) |
  |---|---|
  | Your model + version | Claude Opus 4.8 (`claude-opus-4-8`), 1M context |
  | Harness + version | Claude Code `<version>` (`claude --version`) |
  | All plugins installed | gitban (muunkky.github.io/gitban-site); enumerate any others loaded this session |
  | Human partner who reviewed this diff | Cameron Rout (@muunkky) |

  **NEVER write a sentence describing what gitban does.** Not "an autonomous development harness", not
  "driving the roadmap → PRD → design → ADR → sprint lifecycle", not "with an adversarial reviewer at
  each gate". That is advertising, it is the loudest AI tell in the document, and it gets the PR read as
  slop. A plugin name plus a URL is a disclosure field. A sentence about our lifecycle is a pitch nobody
  asked for.

  Likewise **never narrate our process anywhere in the body** — no review rounds, no overturned designs,
  no sprint story. If the template asks how you tested, answer in one plain sentence about *their* code.

**The test:** a footer that *credits or advertises a vendor* → banned; a *factual answer to "what
produced this?" that the recipient requires* → include, stated plainly and framed as a strength (a
real, filed problem fixed with an honest account of how). gitban is *our own* product — crediting it
is always fine.
