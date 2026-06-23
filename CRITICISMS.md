# Criticisms

Audit timestamp: 2026-06-23 15:42:03 BST.

This is an adversarial review of the current Lean code after the claimed v1
completion. The local Lean core is much better than the old skeleton critique:
the gauge action is concrete, the orbit/fiber bridge is proved, the
first-variation computation is proved, and the squared/unsquared bridge exists.
That does not make the formalization acceptable. It is still a conditional
theorem whose only unproved mathematical input is the largest theorem in the
story, and the documentation is stale in several places.

## 0. Build / Local Status

Local status:

- `lake build` passed: `Build completed successfully (8564 jobs)`.
- `bash scripts/no_sorry.sh` passed: no `sorry`/`admit`/`native_decide`/`axiom`
  under `Project/`.
- `python3 scripts/check_example.py` passed: `max residual = 2.220e-16`.
- `git status --short` failed because this checkout has no `.git` directory at
  `/Users/yangd/Documents/balancedness`; git status is therefore unavailable.
- No `.github` directory exists, so GitHub Actions CI is not configured in this
  checkout.

Aristotle:

- Polled the two old structure critique jobs. Both are now downloaded.
- Prepared standalone N=2 audit inputs:
  `aristotle/aristotle-in/endToEnd_N2.lean`,
  `aristotle/aristotle-in/balanced_N2.lean`,
  `aristotle/aristotle-in/regularizerSq_N2.lean`.
- Each standalone file typechecks locally, with only the intentional target
  `sorry` warning.
- Submitted those three jobs:
  `d5e7a944` (`endToEnd_N2`), `1e2a170e` (`balanced_N2`), and `f555c2f8`
  (`regularizerSq_N2`). They were queued/running at the audit time.
- The submit wrapper warns that single-file submissions lack `lean-toolchain`
  and `.lake` metadata. That is a workflow defect; future Aristotle submissions
  should be directory submissions with explicit toolchain/dependency files.

## 1. Sorry's

I found no `sorry` in `Project/`.

The new Aristotle input files outside `Project/` intentionally contain exactly
one `sorry` each as the proof target. These are not integrated project code.
Their statements are already proved in `Project.Basic`, so Aristotle proving the
negation would indict either the standalone extraction or a serious mismatch
between the standalone definitions and the project definitions. The worst-case
scenario is an orientation error in the public definitions, but the in-project
N=2 lemmas already reduce that risk.

## 2. Hidden Axioms

I found no `admit`, declared `axiom`, `native_decide`, suspicious
`Decidable.decide`, or `unsafe` in `Project/`.

`#print axioms` results:

- `Project.main`: `propext`, `Classical.choice`, `Quot.sound`.
- `Project.main_regularizerSq`: `propext`, `Classical.choice`, `Quot.sound`.
- `Project.KempfNessHyp`: `propext`, `Classical.choice`, `Quot.sound`.
- `Project.fiber_eq_orbit`: `propext`, `Classical.choice`, `Quot.sound`.
- `Project.hasDerivAt_regularizerSq_gaugeExp`: `propext`, `Classical.choice`,
  `Quot.sound`.
- `Project.minimizer_imp_gaugeCritical`: `propext`, `Classical.choice`,
  `Quot.sound`.
- `Project.gaugeCritical_iff_balanced`: `propext`, `Classical.choice`,
  `Quot.sound`.

`KempfNessHyp` is an explicit theorem parameter, not a custom axiom. That is
better than lying with an axiom, but it is still a black-box assumption. Any
unqualified claim that the repository proves Lindsey-Menon unconditionally is
false.

## 3. Circularity

I found no circularity in `Project.Main.main`.

The dependency chain is visible:

- `argmin subset balanced`: `minimizer_imp_gaugeCritical` plus
  `gaugeCritical_iff_balanced`; no Kempf-Ness.
- `balanced subset argmin`: `gaugeCritical_iff_balanced`, then
  `kn.critical_imp_min_on_orbit`, then `fiber_subset_orbit`.
- `fiber_subset_orbit` is the hard `le:group-orbit` step and is proved in
  `GroupAction.lean`; `KempfNessHyp` does not hide it.
- The main set equality constructs no balanced representative and does not use
  SVD.

The remaining circularity risk is not in Lean's dependency graph. It is in the
future discharge of `KempfNessHyp`: if Track B proves the interface by assuming
the DLN balancedness theorem, or by importing a fiber-level minimization theorem,
the whole project becomes circular. The current interface shape prevents the
most obvious fiber-level cheat, but it cannot police the future proof.

## 4. Hypothesis Audit

`Project.main` hypotheses:

- `hX : FullRank X`. Necessary for the current `fiber_subset_orbit` proof. This
  is faithful to v1 and to the paper's stated theorem, but it is stronger than
  the broader mathematical ambition: lower-rank fibers and orbit closures are
  deliberately excluded.
- `kn : KempfNessHyp d L`. Necessary for v1 as a conditional theorem. It is too
  coarse as a formal interface because the real-reductive group, maximal compact
  subgroup, closed-orbit/properness context, `O_d^L` invariance, and
  length-function identification live only in prose.
- Fiber membership in the pointwise inclusions. Necessary and not suspicious.
- Gauge criticality. Defined concretely by `HasDerivAt` of gauge curves, not by
  balancedness or minimality. This avoids the old skeleton failure mode.
- Differentiability. No longer a hidden hypothesis: it is supplied by
  `hasDerivAt_regularizerSq_gaugeExp`. Good, but the proof is specialized to
  real square matrices and the current Frobenius topology workaround.

`KempfNessHyp` itself is stronger than what `Main` actually consumes. `Main`
uses it only at `base = W` for a full-rank fiber point `W`, but the field
quantifies over every orbit. That makes the interface convenient but broader
than the capstone requires.

## 5. Mathematical Correctness

I found no current Lean-level mismatch in the DLN-specific Track A statements:

- Product order is guarded by `endToEnd_N2`.
- Balancedness orientation is guarded by `balanced_N2`.
- The paper's ridge norm is indeed the joint Frobenius norm:
  `||W||_2^2 = sum_k Tr(W_k^* W_k)`, so the `sqrt` bridge is the correct bridge.
- The first variation is proved for `regularizerSq`, and the paper objective is
  reached only through `argmin_regularizerSq_eq_argmin_regularizer`.
- The real-vs-complex caveat is documented in `MomentMap.lean` and
  `KempfNess.lean`.

Real problems remain:

- `O_d^L` invariance (`eq:group-action2`) is only documented and explicitly
  deferred. It is not needed by `Main` because `Main` assumes `KempfNessHyp`, but
  it is a required hypothesis for actually proving `KempfNessHyp`.
- `KempfNessHyp` records real Slodowy provenance in a docstring, not in fields.
  Lean cannot distinguish "proved by the real Richardson-Slodowy theorem" from
  "asserted by a theorem with the same type".
- There is no standalone first-variation N=2 orientation audit. The project has
  the full `le:moments` theorem, but a small N=2 audit would be a cheap guard
  against a future sign/transpose refactor.
- The proof of `le:group-orbit` uses the trivial base instead of the paper's SVD
  center. This is mathematically fine for the set equality, but the paper's
  Occam/canonical-representative interpretation is not formalized.

## 6. Code Quality

No file under `Project/` exceeds 600 lines. I found no `set_option
maxHeartbeats` above 800000. No generated Aristotle proof has been pasted into
the project.

Open code-quality issues:

- `Project/Basic.lean` imports all of `Mathlib`. That was acceptable for
  bootstrapping, but it is a future maintenance liability. The import graph
  should be tightened now that the proof shape is known.
- `Project/GroupAction.lean` still says the `fiber_subset_orbit` proof is
  "deferred to the second pass" even though it is proved. That is stale code
  documentation in a theorem-critical file.
- `Project/MomentMap.lean` still says the two MomentMap bridge proofs are
  "deferred to the second pass" even though they are proved. This is exactly the
  kind of stale comment that makes reviewers distrust status claims.
- The single-file Aristotle submission path is under-specified: it submits only
  a `.lean` file, so Aristotle warns about missing `lean-toolchain` and `.lake`.
  Use directory submissions for serious proof obligations.
- The proof scripts are highly specialized to `Fin`, `Matrix`, and trace API
  details. That is understandable, but several helper lemmas are Mathlib-shaped
  and should not remain trapped in this project forever.

## 7. Documentation Lies

I found real documentation discrepancies:

- `README.md` lines 14-22 are false. They say only `Project.placeholder` exists
  and the target declaration has not been created. In reality,
  `Project.main` and `Project.main_regularizerSq` exist and build.
- `Project/GroupAction.lean` lines 176-184 are stale. The comment says the hard
  orbit proof is deferred; it is now proved in the same file.
- `Project/MomentMap.lean` lines 22-27 are stale. The module docstring says
  `minimizer_imp_gaugeCritical` and `gaugeCritical_iff_balanced` are deferred;
  they are now proved.
- `aristotle/STRUCTURE_CRITIQUE.md` says live submission is blocked until
  `ARISTOTLE_API_KEY` is set. The local `.env` works; jobs were submitted and
  polled in this audit.
- The historical part of `PROGRESS.md` still says the full structure-critique
  Aristotle job is "still running"; it has now been downloaded. Historical logs
  can stay chronological, but the current top section should mention that the
  old full critique is no longer pending and that the N=2 jobs are now queued.
- `CRITICISMS.md` was badly stale before this audit: it still said no
  mathematical result from the paper had been proved. That is now corrected
  here, but the stale README means public-facing status is still dishonest.

I found no issue in `AGENTS.md`'s current status block: it matches the build and
axiom checks from this audit. `FORMALIZATION_PLAN.md` also matches the current
architecture well enough, though it still lists `O_d^L` invariance in the module
plan despite that proof being deferred.

## 8. Generalization Opportunities

Ranked by feasibility:

1. Formalize `O_d^L` invariance of `regularizerSq`. This is low-to-medium risk
   and directly supports the future proof of `KempfNessHyp`.
2. Add a nonemptiness/canonical-representative corollary
   `fiber X ∩ balanced ≠ ∅` using the SVD center. This is off the set-equality
   path but needed for the Occam interpretation.
3. Add a tiny N=2 first-variation audit lemma checking the sign and transpose of
   the moment formula. This is cheap insurance against the most dangerous
   orientation regression.
4. Localize `KempfNessHyp` to the exact full-rank or closed-orbit situation used
   by `Main`, or add formal fields for the KN dictionary (`K`-invariance,
   reductive group, length-function identity). This improves honesty but may
   make Track B harder to state.
5. Extend from real matrices to complex matrices. The source treats complex
   first; the current Lean v1 intentionally avoids it.
6. Attack lower-rank fibers via orbit closures/nullcone stratification. This is
   mathematically important and much harder than v1.
7. Generalize regularizers: Schatten `p` for `1 < p < infinity`, then investigate
   the deliberately excluded `p = 1` case. Do not stub these.

## 9. Mathlib Upstreamability

Specific candidates:

- `reverseProd_conjChain`: a clean noncommutative telescoping lemma for reversed
  products of conjugated chains. This should be generalized away from matrices
  and `GL` if it is upstreamed.
- Prefix product lemmas around `List.ofFn`, `take`, `reverse`, and coercion of
  products of units. The current `preU_succ`/`coe_preU_full` pattern is
  broadly useful but too project-specific as written.
- Matrix determinant/list-product facts used in `factor_isUnit`. Mathlib has
  the ingredients; a packaged lemma saying every factor in a finite matrix
  product is invertible when the product is invertible over a field would be
  useful.
- Frobenius-continuous trace and transpose CLMs. `traceCLM` and `transCLM` are
  local wrappers around existing linear maps; Mathlib could expose canonical
  continuous-linear versions under the Frobenius norm.
- Matrix exponential derivative examples/lemmas under the Frobenius topology.
  The current proof found a real API trap: matrix-valued `HasDerivAt` statements
  can pick the wrong topology. Mathlib documentation or wrapper lemmas should
  make the safe path obvious.
- Trace-pairing nondegeneracy workflows. `Matrix.ext_iff_trace_mul_left` is the
  key lemma, but a named Frobenius/trace-pairing nondegeneracy theorem over
  finite matrices would make proofs like `gaugeCritical_iff_balanced` clearer.

## Verdict

REVISE.

The Lean core for Track A is not fake: it builds, has no project sorries, uses
only standard axioms, proves the DLN-specific orbit and moment calculations, and
keeps Kempf-Ness orbit-level. But it is not acceptable as a completed
formalization of Lindsey-Menon. Acceptance requires, at minimum:

1. Fix the stale public documentation, especially `README.md` and the stale
   module comments in `GroupAction.lean` and `MomentMap.lean`.
2. Package Aristotle submissions with explicit toolchain/dependency metadata and
   process the three queued N=2 audit jobs.
3. Prove or formally expose the `O_d^L` invariance and the real KN dictionary
   obligations needed to discharge `KempfNessHyp`.
4. Eventually discharge `KempfNessHyp` itself, or keep every theorem and document
   brutally explicit that the result is conditional on that unproved interface.

Until those conditions are met, the repository is a strong conditional Track A
formalization, not the theorem.
