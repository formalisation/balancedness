# Prove

Work directly on the highest-priority Lean implementation or proof task. This is
for Claude Code as engineer; keep the reviewer-facing scope in
`FORMALIZATION_PLAN.md` and `CRITICISMS.md` intact.

## Rules

- Before attempting a nontrivial proof, estimate direct proof probability.
- If below about 50%, decompose into smaller named lemmas first.
- After three failed approaches to the same goal, stop and ask for guidance.
- Do not replace hard proof obligations with broader hypotheses.
- Do not silently change agreed theorem statements.

## Steps

1. Read `PROGRESS.md` and `CRITICISMS.md`.
2. Pick one target from the current plan.
3. Inspect the Lean goal with LSP tools if available.
4. Search local project and Mathlib before hand-proving.
5. Edit narrowly.
6. Run the fastest available check on the touched file, then `lake build` when
   the step is complete.
7. Run `bash scripts/no_sorry.sh` when the module is meant to be proof-complete.

If a lemma is true but too hard, extract a standalone Aristotle submission under
`aristotle/aristotle-in/` and use `/submit-aristotle`, while continuing to work
on decomposed sublemmas locally.
