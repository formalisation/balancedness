# Aristotle Structure Critique

Prepare the proposed Lean structure for Aristotle-style scrutiny before major
implementation work.

Important limitation: Aristotle consumes Lean proof obligations. It cannot review
architecture prose directly. The right workflow is:

1. Keep `aristotle/STRUCTURE_CRITIQUE.md` current with the proposed Lean API and
   reviewer questions.
2. Once `Project/Basic.lean` contains the first real declarations, extract
   standalone source-audit lemmas into `aristotle/aristotle-in/`, for example:
   - `endToEnd_N2`;
   - `balanced_N2`;
   - `regularizerSq_N2`;
   - small counterexample-search lemmas for questionable definitions.
3. Submit those standalone Lean files with `/submit-aristotle`.
4. Treat a failed or negated result as a definition-review signal, not merely as
   a proof failure.

If the Aristotle CLI or API key is unavailable, record the blocker in
`PROGRESS.md` and keep the payload files ready.
