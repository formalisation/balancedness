# Criticisms

Audit timestamp: 2026-06-23 17:06:10 BST.

Hostile re-review after the previous (15:42 BST) audit. The Lean core for Track A
is genuinely non-trivial and builds clean, but this is **not** an accepted
formalization of Lindsey-Menon, and — damningly — the previous audit's two most
embarrassing findings (a public `README.md` that lies about the entire project
status, and stale "deferred to the second pass" comments sitting directly above
the proofs they claim are missing) are **still unfixed**. A review cycle that
re-flags the same documentation lies without fixing them is not making progress.

## 0. Build / Local Status

- `lake build`: PASS — `Build completed successfully (8564 jobs)`.
- `bash scripts/no_sorry.sh`: PASS — `sorry-gate: OK (no
  sorry/admit/native_decide/axiom in Project/)`.
- `#print axioms Project.main` / `Project.main_regularizerSq`: only `propext`,
  `Classical.choice`, `Quot.sound`. No custom axioms. Re-verified this cycle.
- `git status`: clean except `state.md` (babysit scratch). `.git` IS present
  here (the previous audit wrongly claimed it was missing — that earlier claim
  was itself a status error).
- No `.github/` directory: GitHub Actions CI is not configured in this checkout.
  The only oracle is local `lake build` + `no_sorry.sh`.

No P0 build regressions. The P0s below are documentation/honesty, which for a
formalization whose entire value proposition is trust are not cosmetic.

## 1. Sorry's

No `sorry` in `Project/`. Confirmed by `no_sorry.sh` and by inspection of all
five modules.

The three N=2 audit files under `aristotle/aristotle-in/` each carry one
intentional target `sorry`; they are git-ignored (`.gitignore` excludes
`aristotle/aristotle-in/**/*.lean`) and not part of the build. Their statements
are already proved in `Project.Basic` (`endToEnd_N2`, `balanced_N2`,
`regularizerSq_N2`), so they are redundant as proof targets — their only value is
an *independent* re-derivation by Aristotle. Those three jobs are still
`submitted` (queued) per `aristotle/aristotle-jobs.json` and have produced
nothing; until they return, they buy zero additional assurance.

## 2. Hidden Axioms

No `admit`, declared `axiom`, `native_decide`, suspicious `Decidable.decide`, or
`unsafe` under `Project/`. Axiom check re-run this cycle (see §0).

`KempfNessHyp` is an explicit `structure ... : Prop` hypothesis threaded through
`main`/`main_regularizerSq`, not a Lean `axiom`. That is the honest encoding. But
it remains the single largest mathematical input of the entire paper, unproved.
**Any claim that this repo proves Lindsey-Menon unconditionally is false**, and
the README must say so where users actually read it (it currently says something
far worse — see §7).

## 3. Circularity

No circularity in Lean's dependency graph for `Project.main`:

- `argmin ⊆ balanced`: `minimizer_imp_gaugeCritical` then
  `gaugeCritical_iff_balanced`. No Kempf-Ness.
- `balanced ⊆ argmin`: `gaugeCritical_iff_balanced`, then
  `kn.critical_imp_min_on_orbit`, then `fiber_subset_orbit`.
- `fiber_subset_orbit` (the hard `le:group-orbit` step) is genuinely proved in
  `GroupAction.lean` via `mem_orbit_trivialBase` (SVD-free sequential
  gauge-solve). `KempfNessHyp` does not hide it.
- The set equality builds no representative and uses no SVD.

The unpoliceable risk is Track B: if `KempfNessHyp` is later discharged by
assuming a fiber-level minimization theorem (or the balancedness theorem
itself), the whole edifice becomes circular. The orbit-level interface shape
blocks the most obvious cheat but cannot constrain a future proof. This is a
standing risk, not a current defect.

## 4. Hypothesis Audit

- `hX : FullRank X` (= `IsUnit X`). Necessary for `factor_isUnit` /
  `mem_orbit_trivialBase`. Faithful to the paper's full-rank theorem, but
  strictly stronger than the broader ambition (lower-rank fibers, orbit
  closures) which v1 deliberately excludes.
- `kn : KempfNessHyp d L`. Necessary for v1 as a conditional theorem, but
  **over-broad**: the field `critical_imp_min_on_orbit` quantifies over *every*
  `base` and every orbit, whereas `main` instantiates it exactly once at
  `base = W` for a full-rank fiber point. A faithful interface would be localized
  to the full-rank / closed-orbit situation actually used, making the eventual
  Track B obligation honest about what must be proved. As written, it is
  convenient for `Main` and harder than necessary to discharge.
- `KempfNessHyp` provenance (real reductive `(GL_d ℝ)^L`, maximal compact
  `O_d^L`, `K`-invariance of `regularizerSq`, identification with the KN length
  function) lives only in the docstring, **not in fields**. Lean cannot tell
  "proved by Richardson-Slodowy" from "asserted by a same-typed theorem". A
  reviewer cannot trust prose to prevent the complex KN theorem being substituted
  for the real one during Track B.
- Fiber membership and gauge criticality: necessary and not suspicious. Gauge
  criticality is defined from `HasDerivAt` of gauge curves
  (`GaugeCritical`), independently of balancedness — `gaugeCritical_iff_balanced`
  is a real bridge, not a definitional restatement. Good.
- Differentiability is supplied (not assumed) by
  `hasDerivAt_regularizerSq_gaugeExp`. Good, but specialized to real square
  matrices and the Frobenius-topology workaround.

## 5. Mathematical Correctness

No Lean-level mismatch found in the DLN-specific Track A statements:

- Product order guarded by `endToEnd_N2` (`![W₁,W₂] ↦ W₂*W₁`).
- Balancedness orientation guarded by `balanced_N2` (`W₁W₁ᵀ = W₂ᵀW₂`).
- Ridge norm is the joint Frobenius norm; the `sqrt` bridge
  (`isMinOn_regularizerSq_iff_regularizer`,
  `argmin_regularizerSq_eq_argmin_regularizer`) is the correct route to the
  unsquared `eq:variation1`.
- First variation proved for `regularizerSq` only; the paper objective is reached
  only through the bridge. Matches the invariant "never differentiate the
  unsquared norm".

Real gaps remain:

- `O_d^L` invariance (`eq:group-action2`) is only documented and deferred. Not
  needed by `main` (which assumes `KempfNessHyp`), but it is a *required input*
  to ever prove `KempfNessHyp`. Until it exists, Track B is not even staged.
- **N=2 first-variation orientation audit. [FIXED 2026-06-23 17:06 cycle.]**
  `hasDerivAt_regularizerSq_gaugeExp_N2` (in `MomentMap.lean`) now pins the `L = 1`
  first variation to `2·Tr(a₀·(W₁W₁ᵀ − W₂ᵀW₂))`: coefficient, left-multiplication
  by the direction, moment sign, and transpose placement are all guarded against a
  future refactor. Additionally corroborated externally by the three completed
  Aristotle N=2 audits of the underlying definitions.
- `le:group-orbit` is proved from `trivialBase = (X,1,…,1)`, not the paper's SVD
  center. Fine for the set equality, but the Occam/canonical-representative
  reading (and `fiber X ∩ balanced ≠ ∅`) is not formalized.

## 6. Code Quality

No file exceeds 600 lines (largest: `GroupAction.lean` 281, `MomentMap.lean`
279). No `set_option maxHeartbeats`. No generated Aristotle proof pasted into
`Project/`.

Open issues:

- **`Project/Basic.lean` line 1: `import Mathlib`.** Whole-Mathlib import. The
  proof shape is now fully known; this should be tightened to granular imports.
  Every downstream module inherits it transitively, so the entire build pays for
  it. Maintenance liability and a slow-build tax.
- **Stale tracked Aristotle outputs.** `git ls-files` shows the *completed*
  `structure-critique` and `structure-critique-minimal` job outputs
  (`ARISTOTLE_SUMMARY.md`, `structure-critique-response.md`, `lake-manifest.json`,
  toolchains, etc.) committed under `aristotle/aristotle-out/...`. These are
  generated artifacts from one-off planning jobs; keeping them in version control
  is clutter and risks confusing future readers about what is source vs. output.
  Decide: either gitignore the whole `aristotle-out/` tree (consistent with the
  existing `*.lean`/`*.tar.gz` ignores) or keep only a short human summary.
- The Aristotle single-file submission path (`endToEnd_N2.lean`, etc.) submits a
  bare `.lean` with no `lean-toolchain`/`.lake` metadata; the wrapper warns about
  this. Serious proof obligations must be directory submissions with explicit
  toolchain/dependency files. The N=2 jobs were submitted the under-specified way.
- Helper lemmas (`reverseProd_conjChain`, `preU`/`preU_succ`/`coe_preU_full`,
  `factor_isUnit`, `traceCLM`/`transCLM`) are Mathlib-shaped but trapped in this
  project (see §9).

## 7. Documentation Lies

These are the gating defects. Two were flagged in the previous audit and **not
fixed** — re-flagging them is not progress; fixing them is.

- **P0 — `README.md` lies. [FIXED 2026-06-23 17:06 cycle.]** Was: "only the
  template theorem `Project.placeholder` exists. No mathematical theorem from the
  paper has been formalized yet." + "target declaration, not yet created". Now
  rewritten to state the real conditional-theorem status (`main` /
  `main_regularizerSq`, sorry-free, axiom-clean, modulo `KempfNessHyp`) with a
  corrected status table and module Layout. Verified `lake build` green after.
- **P1 — `Project/GroupAction.lean` stale `le:group-orbit` docstring.
  [FIXED 2026-06-23 17:06 cycle.]** Rewritten to describe the proof that exists
  (`factor_isUnit`/`preU`/`mem_orbit_trivialBase`/`fiber_subset_orbit`), no longer
  "deferred to the second pass".
- **P1 — `Project/MomentMap.lean` stale two-bridge docstring.
  [FIXED 2026-06-23 17:06 cycle.]** Rewritten to say both bridges are proved below
  from `le:moments`, naming the mechanisms (`IsLocalMin.hasDerivAt_eq_zero`,
  `Matrix.ext_iff_trace_mul_left`).
- **P2 — `aristotle/STRUCTURE_CRITIQUE.md` blocked-submission claim.
  [FIXED 2026-06-23 17:06 cycle.]** Updated to record that submission works from
  local `.env` and that the structure + three N=2 jobs are all downloaded.
- **P2 — `FORMALIZATION_PLAN.md` `O_d^L` listed as planned/done.
  [FIXED 2026-06-23 17:06 cycle.]** Module plan now marks `O_d^L` invariance
  explicitly deferred (off the v1 set-equality path; Track B input).
- `PROGRESS.md` top section: acceptable now (it notes v1 complete and sorry-free),
  but it does not mention that the N=2 Aristotle jobs are queued/unreturned or
  that the structure jobs are downloaded. Minor.

`AGENTS.md` status block matches the build/axiom reality — no issue found there.

## 8. Generalization Opportunities

Ranked by feasibility:

1. **N=2 first-variation audit lemma** (cheapest, do now). A guard
   `hasDerivAt_regularizerSq_gaugeExp` at `L = 1` pinning
   `∑_j 2·Tr(a_j G_j)` sign/transpose. Pure regression insurance, low risk.
2. **Localize `KempfNessHyp`** to the full-rank/closed-orbit case `Main` uses, or
   add formal fields for the KN dictionary (`O_d^L` invariance, reductive group,
   length-function identity). Improves honesty; may make Track B statement harder.
3. **`O_d^L` invariance of `regularizerSq`** (`eq:group-action2`). Low-to-medium
   risk, directly supports discharging `KempfNessHyp`.
4. **Nonemptiness / canonical-representative corollary** `fiber X ∩ balanced ≠ ∅`
   via the SVD center. Off the set-equality path; needed for the Occam reading.
5. **Complex matrices.** The source treats `ℂ` first; v1 intentionally avoids it.
   Requires conjugate-transpose moment map and complex KN.
6. **Lower-rank fibers** via orbit closures / nullcone stratification. Much harder
   than v1.
7. **Schatten `p` regularizers** for `1 < p < ∞`, then the excluded `p = 1`. Do
   not stub.

## 9. Mathlib Upstreamability

- `reverseProd_conjChain`: clean noncommutative telescoping of reversed products
  of conjugated chains. Generalize off `Matrix`/`GL` (any monoid + units) to
  upstream.
- `preU`/`preU_succ`/`coe_preU_full`: prefix-product-of-units lemmas over
  `List.ofFn`/`take`/`reverse`. Broadly useful; currently too project-specific.
- `factor_isUnit`: "every factor of an invertible finite matrix product over a
  field is invertible" — Mathlib has the pieces; a packaged lemma would be useful.
- `traceCLM`/`transCLM`: Frobenius-continuous trace and transpose as CLMs. Mathlib
  could expose canonical continuous-linear versions under the Frobenius norm.
- Matrix exponential derivative under the Frobenius topology: the proof hit a real
  instance-diamond trap (default Pi vs. Frobenius topology). A documented wrapper
  lemma / `HasDerivAt` example would save the next person the same workaround.
- Trace-pairing nondegeneracy: `Matrix.ext_iff_trace_mul_left` drives
  `gaugeCritical_iff_balanced`; a named Frobenius/trace-pairing nondegeneracy
  theorem over finite matrices would clarify such proofs.

## Verdict

REVISE.

The Track A Lean core is real: it builds, has no project sorries, uses only
standard axioms, proves the DLN-specific orbit and moment calculations, and keeps
Kempf-Ness orbit-level and SVD-free. It is a strong *conditional* formalization.
It is **not** the theorem, and it is not acceptable while its public-facing
documentation describes an empty repository.

Conditions for acceptance (all must be fixed):

1. **[P0] DONE (this cycle).** `README.md` rewritten to state the real
   conditional Track A status modulo `KempfNessHyp`; placeholder lies deleted.
2. **[P1] DONE (this cycle).** Stale "deferred to the second pass" comments in
   `GroupAction.lean` and `MomentMap.lean` rewritten to describe the proofs.
3. **[P2] DONE (this cycle).** `aristotle/STRUCTURE_CRITIQUE.md` blocked claim
   fixed; `O_d^L` invariance marked deferred in `FORMALIZATION_PLAN.md`.
4. **[strengthen] DONE (this cycle).** N=2 first-variation orientation audit
   lemma `hasDerivAt_regularizerSq_gaugeExp_N2` added and proved; `lake build` +
   sorry-gate green. Externally corroborated by the completed Aristotle N=2 audits.
5. **[code quality] PARTIAL.** Tracked `aristotle-out/` generated artifacts
   **DONE (this cycle)**: the whole output tree is now gitignored (except
   `.gitkeep`) and the previously-committed structure-critique outputs were
   untracked via `git rm --cached` (files preserved on disk). Still OPEN:
   tighten `Project/Basic.lean`'s whole-`Mathlib` import (deferred to a dedicated
   cycle — build-time-sensitive).
6. **[interface honesty]** Localize `KempfNessHyp` or add formal KN-dictionary
   fields; eventually discharge it or keep every claim brutally explicit that the
   result is conditional on it.
7. **[Aristotle]** Re-submit the N=2 audits as directory packages with toolchain
   metadata; process the three queued jobs.

Until at least conditions 1-4 are met, this remains a strong conditional Track A
formalization, not the Lindsey-Menon theorem.
