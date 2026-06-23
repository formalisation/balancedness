# Simplify

Fix code quality and maintainability issues without changing mathematical scope.

## Targets

- stale documentation;
- oversized files;
- duplicated definitions;
- unnecessary imports;
- high heartbeat proofs;
- long monolithic proofs that should be factored into lemmas;
- dead generated Aristotle files.

## Workflow

1. Read `CRITICISMS.md` and `PROGRESS.md`.
2. Pick one bounded issue.
3. Apply the smallest refactor that fixes it.
4. Run `lake build`.
5. Update `CRITICISMS.md` or `PROGRESS.md` if the issue status changed.

Do not use this command for new theorem-proving work; use `/prove`.
