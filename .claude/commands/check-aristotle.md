# Check Aristotle

Poll Aristotle jobs and process completed results.

## Steps

1. Run:

   ```bash
   .venv/bin/python aristotle/check-aristotle.py
   ```

2. For each completed job saved under `aristotle/aristotle-out/`:
   - inspect whether the output has remaining proof gaps;
   - compare the standalone statement to the target project statement;
   - integrate only after understanding the proof and any helper assumptions;
   - verify the touched project file with Lean.

3. For failed, expired, or negated jobs:
   - update `aristotle/aristotle-jobs.json` notes if needed;
   - record whether the statement needs decomposition, stronger hypotheses, or
     abandonment.

4. Update `PROGRESS.md` with the job status summary.

Do not paste large Aristotle-generated proofs blindly. Keep integration small and
reviewable.
