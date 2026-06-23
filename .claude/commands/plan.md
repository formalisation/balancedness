# Plan

Analyze the current state and produce a prioritized work plan in `PROGRESS.md`.

## Gather state

- Read `CRITICISMS.md` (in the `/babysit` cycle, `/critique` has just refreshed
  it), `FORMALIZATION_PLAN.md`, `AGENTS.md`, and `README.md`.
- Read the relevant Lean files in `Project/`.
- Run `rg -n "sorry|admit|axiom|native_decide" Project`.
- Check `aristotle/aristotle-jobs.json` for pending, failed, or negated jobs.

## Classify issues

- P0: build failure or broken proof-gap gate.
- P1: incorrect theorem statement or hidden assumption.
- P2: missing core v1 definitions/proofs.
- P3: architecture risk, indexing drift, overbroad interface.
- P4: stale docs or cleanup.

## Write the plan

Update `PROGRESS.md` with:

- current status;
- active multi-cycle strategy;
- this cycle's work items;
- risks and blockers;
- what should be submitted to Aristotle, if anything.

The first work item must be immediately executable. Do not use "waiting for
Aristotle" as the only plan; work on decomposition or direct proof in parallel.
