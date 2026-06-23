# Claude Code Instructions

You are the implementation engineer for this Lean 4 + Mathlib formalization.
Codex/the human reviewer owns mathematical direction, critiques statements, and
accepts or rejects architecture changes. Your job is to implement the agreed
plan carefully, keep Lean compiling, and surface blockers early.

## Project Target

Formalize Kathryn Lindsey and Govind Menon, *Regularization Implies
balancedness in the deep linear network*, arXiv:2511.01137.

Version 1 is the real, full-rank L2 theorem, conditional on the named
Kempf-Ness interface `KempfNessHyp`:

```text
argmin_{W in fiber X} ||W||_2 = fiber X intersection balanced
```

Read these before changing Lean code:

- `FORMALIZATION_PLAN.md` - authoritative module plan and sequencing.
- `CRITICISMS.md` - active risks and design invariants.
- `AGENTS.md` - accumulated project memory and proof workflow.
- `PROGRESS.md` - current status and next task.

## Role Contract

- Implement the plan; do not silently redesign it.
- Ask Codex/the human reviewer before changing theorem statements, broadening
  hypotheses, moving SVD onto the main theorem path, or changing the
  `KempfNessHyp` interface.
- Prefer honest skeletons over wrong statements, but keep committed Lean code
  free of `sorry`, `admit`, `axiom`, and `native_decide` unless the reviewer
  explicitly approves an interface axiom.
- If a proof goal resists three materially different approaches, stop and ask
  for guidance with the exact goal and failed approaches.
- Do not send alerts, consult external chat models, or run CI/deploy workflows.
  Committing and pushing are sanctioned only through the `/commit` babysit step
  (push to a topic branch, never force-push or push directly to the default
  branch).

## V1 Design Invariants

- Index by gauge layers `L`: weights `Fin (L+1)`, gauges/moments `Fin L`.
- Orientation is ascending: Lean index `0` is paper `W_1`; product reverses the
  tuple so `endToEnd ![W1, W2] = W2 * W1`.
- Prove first against `regularizerSq`; translate to the paper's norm later by a
  monotonicity lemma. Never differentiate the unsquared norm.
- Full rank is invertibility / nonzero determinant, not general rank theory.
- Criticality is concrete: derivative at zero of gauge curves, not manifold
  infrastructure.
- `KempfNessHyp` is orbit-level, not fiber-level. `Main` must use
  `le:group-orbit`; the interface must not hide that paper step.
- The main set equality is SVD-free. SVD is only for later nonemptiness or
  canonical-representative corollaries.

## Aristotle Workflow

This repo uses the autonomous autoformalization lifecycle from the Clawristotle
template, adapted to this project (no Telegram `alert` step). One `/babysit` cycle
runs, in order: `/critique` → `/plan` → `/submit-aristotle` → `/prove` →
`/check-aristotle` → `/simplify` → `/strengthen` → `/log` → `/cleanup` →
`/commit`. Every step must run and every cycle must make progress (see
`babysit.md`). `/critique` opens the cycle with an adversarial self-review that
refreshes `CRITICISMS.md`; Codex/the human reviewer still owns an independent
adversarial critique (`.codex/commands/critique.md`).

Available commands live in `.claude/commands/`:

- `critique`
- `babysit`
- `plan`
- `aristotle-structure-critique`
- `submit-aristotle`
- `prove`
- `check-aristotle`
- `simplify`
- `strengthen`
- `log`
- `cleanup`
- `commit`

Use the project-local Aristotle installation:

```sh
.venv/bin/aristotle --version
.venv/bin/python aristotle/check-aristotle.py
```

The real API key is in local `.env`; never print it, copy it into tracked files,
or include it in logs. Generated Aristotle Lean submissions and outputs belong
under `aristotle/aristotle-in/` and `aristotle/aristotle-out/`.

Before substantial implementation of `Project/Basic.lean`, prepare the structure
review payload with `aristotle-structure-critique`. Once real definitions exist,
prepare standalone Aristotle checks for:

- `endToEnd_N2`
- `balanced_N2`
- `regularizerSq_N2`
- small definition-sanity lemmas suggested by the reviewer

## Verification

Use Lean LSP/MCP tools as the inner loop when available. Run full checks at
module boundaries:

```sh
lake build
bash scripts/no_sorry.sh
```

For Aristotle tooling:

```sh
.venv/bin/python -m py_compile aristotle/check-aristotle.py
.venv/bin/python aristotle/check-aristotle.py
```

Record completed work in `PROGRESS.md`. Put reusable proof lessons and exact
Mathlib API signatures in `AGENTS.md`.
