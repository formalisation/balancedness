# Submit Aristotle

Prepare and submit standalone Lean lemmas to Aristotle.

This command requires the project `.venv` with `aristotlelib` installed and a
configured Aristotle API key. If either is missing, report that clearly and leave
the input files in `aristotle/aristotle-in/` for later submission.

## Input format

Each submission should be a standalone `.lean` file in
`aristotle/aristotle-in/` with:

- `import Mathlib` or the smallest standalone imports available;
- exactly one target lemma/theorem with a proof gap;
- all supporting definitions and helper lemmas inline;
- no custom `axiom`;
- a short comment naming the source file and intended integration point.

Aristotle is for hard, isolated Lean proof obligations or counterexample search.
It is not a substitute for reviewing prose architecture.

## Submit

Use:

```bash
.venv/bin/python aristotle/check-aristotle.py submit aristotle/aristotle-in/NAME.lean
```

The script records job IDs in `aristotle/aristotle-jobs.json`.

## Failure handling

- Missing library/API key: report the missing dependency, do not retry.
- Syntax/type error: fix the standalone file before submitting.
- Aristotle returns a proof with gaps: decompose and resubmit smaller lemmas.
- Aristotle proves/disproves the negation: treat the original statement as
  suspect and review hypotheses before resubmitting.
