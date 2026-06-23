# Cleanup

Remove stale local artifacts and dead code.

## Aristotle files

- Keep pending submissions in `aristotle/aristotle-in/`.
- Keep completed outputs in `aristotle/aristotle-out/` until integrated and
  reviewed.
- Delete generated input/output files only after confirming the job is obsolete
  or integrated.
- Keep `aristotle/aristotle-jobs.json` as the authoritative job ledger.

## Project files

- Remove dead comments and unused generated artifacts.
- Do not delete source papers, notes, or user-created files.
- Do not run destructive Git commands.

Report what was deleted and why.
