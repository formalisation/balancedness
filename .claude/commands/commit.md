# Commit

Commit and push all changes.

Do not stage or commit secrets. The repository's `.gitignore` already excludes
`.env`, `.venv/`, `.lake/`, and generated Aristotle inputs/outputs; never override
it to force-add those.

Steps:

1. Identify all modified `.lean` files (via `git status`). Force a rebuild of each by deleting its `.olean` and rebuilding, to catch errors a stale cache might hide:
   ```
   for f in <modified Project/*.lean files>; do
     mod=$(echo "${f%.lean}" | sed 's|/|.|g')
     rm -f ".lake/build/lib/lean/${f%.lean}.olean"
     lake build "$mod" 2>&1 | grep -i "error"
   done
   ```
   Sorry warnings are OK here, but errors are NOT. If any file fails, fix the errors first — do NOT commit broken code. Then run `bash scripts/no_sorry.sh`; do not commit if the sorry-gate is red unless the cycle is intentionally leaving a documented gap.

   If no `.lean` files were modified, run `lake build` as a basic sanity check.

2. Stage changed files under `Project/`, `scripts/`, `aristotle/` (ledger/scripts only), the docs (`*.md`), and `.claude/commands/`. Do NOT stage:
   - `.env` or other secrets;
   - large binary files (papers PDFs, generated extracts);
   - generated Aristotle `*.lean` inputs/outputs (gitignored);
   - files in `.claude/` other than `commands/`.

3. Write a concise commit message summarizing what changed (sorry count, files added/split/deleted, proofs closed, hypotheses weakened, etc.). End the message with:
   ```
   Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
   ```

4. Push to the current branch. If the working branch is the default branch, create a topic branch first rather than pushing directly to it.
