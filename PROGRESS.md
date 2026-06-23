# Progress Log

Running narrative of the formalization: what got done, what is next, and which
risks remain active. Reusable proof lessons and exact Mathlib API signatures
belong in `AGENTS.md`; this file is the story and sequencing.

## Current plan (babysit cycle, 2026-06-23 17:06 BST)

**State.** **v1 is complete and sorry-free.** `lake build` green (8564 jobs),
`bash scripts/no_sorry.sh` passes, `#print axioms Project.main` shows only
`propext`/`Classical.choice`/`Quot.sound` (re-verified this cycle). The capstone
`Main.main` (`thm:intro`/`eq:variation1`) is a real conditional theorem modulo the
single `KempfNessHyp` interface.

**Multi-cycle strategy.** v1 is mathematically assembled; the remaining work is
(a) honesty/cleanup so the public docs match reality, (b) cheap regression
insurance on the one analytic lemma, then (c) staging Track B (`O_d^L`
invariance → discharge `KempfNessHyp`). No P0/P1/P2 issues are open.

**Issue classification (this cycle, from `CRITICISMS.md`):**
- P0 (build / gate): none. Build green, sorry-gate green.
- P1 (wrong statement / hidden assumption): none. `KempfNessHyp` is an honest
  explicit hypothesis (axiom-clean); statements guarded by N=2 lemmas.
- P2 (missing core v1): none. v1 set equality is complete.
- P3 (architecture / overbroad interface): `KempfNessHyp` quantifies over every
  orbit though `Main` uses only `base = W`; no N=2 first-variation orientation
  guard; `O_d^L` invariance deferred (blocks Track B).
- P4 (stale docs / cleanup): **`README.md` lies** (claims only
  `Project.placeholder` exists — it does not exist at all); stale "deferred to the
  second pass" comments in `GroupAction.lean` and `MomentMap.lean`; stale
  blocked-submission claim in `aristotle/STRUCTURE_CRITIQUE.md`; `O_d^L` listed as
  planned in `FORMALIZATION_PLAN.md`; whole-`Mathlib` import in `Basic.lean`;
  tracked generated `aristotle-out/` artifacts.

**This cycle's work items (in order):**
1. **[/simplify, executable now] Fix `README.md`** — replace the
   `Project.placeholder`/"not yet created" falsehoods with the real conditional
   Track A status (`main`/`main_regularizerSq` modulo `KempfNessHyp`, sorry-free,
   axiom-clean). This was flagged last cycle and not fixed; it is the top item.
2. **[/simplify] Remove stale comments** in `GroupAction.lean` (the
   `le:group-orbit` "deferred" docstring) and `MomentMap.lean` (the two-bridge
   "deferred" docstring); describe the proofs that now exist.
3. **[/simplify] Fix remaining stale docs**: `aristotle/STRUCTURE_CRITIQUE.md`
   blocked claim; mark `O_d^L` invariance deferred in `FORMALIZATION_PLAN.md`.
4. **[/strengthen] Add the N=2 first-variation orientation audit** — an `L = 1`
   specialization of `hasDerivAt_regularizerSq_gaugeExp` pinning the sign and
   transpose of `∑_j 2·Tr(a_j G_j)`. Cheap insurance for the one analytic lemma;
   provable directly, no Aristotle needed.
5. **[/cleanup] Decide the fate of tracked `aristotle-out/` artifacts** (gitignore
   the tree or keep a short summary); consider tightening `Basic.lean`'s import
   in a later cycle (larger, build-time-sensitive — not this cycle).

**Aristotle.** The three N=2 audit jobs (`d5e7a944` `endToEnd_N2`, `1e2a170e`
`balanced_N2`, `f555c2f8` `regularizerSq_N2`) **all COMPLETED and downloaded**
this cycle. Aristotle independently re-proved each from standalone definitions
that match `Project.Basic` byte-for-byte (modulo `W₁`→`W1` naming), all
axiom-clean (`propext`/`Classical.choice`/`Quot.sound`). This independently
confirms the product order (`![W1,W2] ↦ W2*W1`), the balancedness orientation
(`W1W1ᵀ = W2ᵀW2`), and the regularizer expansion are not reversed — a review-gate
win. No code integration needed (already proved in-project). No new heavy job is
warranted this cycle: the only unproved math (`KempfNessHyp`) is an intentional
Track B interface, and item 4 is a direct Lean proof. The extracted outputs land
under `aristotle/aristotle-out/{endToEnd,balanced,regularizerSq}_N2_aristotle/`
(cleanup item: gitignore the tree). If a future cycle submits `O_d^L` invariance,
package it as a directory with toolchain metadata.

**Risks / blockers.** (1) The README lie has survived a full cycle — fixing it is
mandatory this cycle. (2) Track B circularity risk: `KempfNessHyp` must not be
discharged via any fiber-level minimization theorem. (3) Tightening the
whole-Mathlib import risks long rebuilds; defer to a dedicated cycle.

**Backburner - explicitly deferred.** Complex matrices, lower-rank fibers,
Schatten `p`, L1, regularizing flows, Kirwan-Ness flow, learning-flow geometry,
full affine GIT, good quotients, and the SVD canonical-representative /
nonemptiness corollary (`fiber X ∩ balanced ≠ ∅`).

---

## Session 2026-06-23 (PM) - Babysit cycle: doc-honesty pass + N=2 first-variation audit

**Done (build green, sorry-gate green, `main` axiom-clean — all re-verified).**

- **Aristotle N=2 audits returned and verified.** All three queued jobs completed
  and downloaded: `d5e7a944` (`endToEnd_N2`), `1e2a170e` (`balanced_N2`),
  `f555c2f8` (`regularizerSq_N2`). Each was proved by Aristotle from standalone
  definitions matching `Project.Basic` byte-for-byte (modulo `W₁`→`W1`),
  axiom-clean. Independent external confirmation that product order, balancedness
  orientation, and regularizer expansion are not reversed. No code integration
  needed (already proved in-project). Ledger `aristotle/aristotle-jobs.json`
  updated by the polling script; extracts under
  `aristotle/aristotle-out/{endToEnd,balanced,regularizerSq}_N2_aristotle/`.
- **N=2 first-variation orientation audit added** (`/strengthen`).
  `Project/MomentMap.lean`: `hasDerivAt_regularizerSq_gaugeExp_N2` pins the `L = 1`
  first variation to `2·Tr(a₀·(W₁W₁ᵀ − W₂ᵀW₂))` — guarding the coefficient,
  left-multiplication by the direction, the moment sign, and the transpose
  placement of `le:moments` against a future refactor. Proof: specialize
  `hasDerivAt_regularizerSq_gaugeExp` at `L = 1`, `Fin.sum_univ_one`, and
  `simp [moment]` for the explicit moment. Companion to the `Basic.lean` N=2 gate.
- **Documentation-honesty pass** (`/simplify`), fixing the previous cycle's
  unfixed `CRITICISMS.md` findings:
  - `README.md` — the P0 lie ("only `Project.placeholder` exists … target
    declaration, not yet created") replaced with the true conditional-theorem
    status (`main` / `main_regularizerSq`, sorry-free, axiom-clean, modulo
    `KempfNessHyp`), corrected status table, and accurate module Layout.
  - `Project/GroupAction.lean` — stale "`le:group-orbit` … deferred to the second
    pass" docstring rewritten to describe the SVD-free gauge-solve that is proved.
  - `Project/MomentMap.lean` — stale "two bridges … deferred to the second pass"
    docstring rewritten to say both are proved from `le:moments`.
  - `aristotle/STRUCTURE_CRITIQUE.md` — stale "submission blocked until API key"
    claim corrected (submission works; all jobs downloaded).
  - `FORMALIZATION_PLAN.md` — `O_d^L` invariance marked explicitly deferred in the
    `GroupAction.lean` module plan.
- **Docs synced.** `CRITICISMS.md` items marked FIXED/DONE with this cycle's
  timestamp; `AGENTS.md` status block notes the new N=2 audit lemma.

**Files changed.** `README.md`, `Project/GroupAction.lean` (docstring),
`Project/MomentMap.lean` (docstring + new lemma), `aristotle/STRUCTURE_CRITIQUE.md`,
`FORMALIZATION_PLAN.md`, `CRITICISMS.md`, `AGENTS.md`, `PROGRESS.md`,
`aristotle/aristotle-jobs.json` (script-updated).

**Declarations added.** `hasDerivAt_regularizerSq_gaugeExp_N2` (`MomentMap.lean`).

**Verification.** `lake build` (8564 jobs, green), `bash scripts/no_sorry.sh`
(green), `#print axioms Project.main` / `Project.main_regularizerSq`
(`propext`/`Classical.choice`/`Quot.sound` only),
`.venv/bin/python aristotle/check-aristotle.py` (3 N=2 jobs complete).

**Remaining risks / blockers.** (1) Capstone still conditional on the unproved
`KempfNessHyp` interface (Track B). (2) `KempfNessHyp` is over-broad vs. what
`Main` uses and records provenance only in prose — localizing/field-ifying it
needs reviewer sign-off (interface change). (3) `O_d^L` invariance still unproved
(blocks Track B). (4) `Basic.lean` whole-`Mathlib` import (build-time-sensitive;
deferred to a dedicated cycle). (5) Tracked generated `aristotle-out/` artifacts
to be triaged in `/cleanup`.

---

## Session 2026-06-23 - Phase 8: `le:moments` + both MomentMap bridges (v1 sorry-free)

**Done (sorry-free; `lake build` + `no_sorry.sh` green; `main` axiom-clean).** The last
two sorries in the project are gone. In `Project/MomentMap.lean`:
- **`le:moments`** (`hasDerivAt_regularizerSq_gaugeExp`):
  `d/dt|₀ regularizerSq(gaugeExp t a • W) = ∑_j 2·Tr(a_j G_j)` — v1's one genuine
  analytic step. Built from a reusable single-layer lemma `hasDerivAt_summand`
  (`d/dt|₀ Tr((e^{tb} W e^{tc})ᵀ(e^{tb} W e^{tc}))`), summed over layers, then the trace
  algebra `sum_perSummand` reindexes the `Fin (L+1)` weight sum to the `Fin L` moment sum.
- **`minimizer_imp_gaugeCritical`** — assembled from `gaugeCurve_mem_fiber` (curve stays in
  fiber ⇒ `t=0` is a global min of `g t = regularizerSq(gaugeExp t a • W)`), `le:moments`
  (`g` differentiable), and `IsLocalMin.hasDerivAt_eq_zero`. **No Kempf-Ness.**
- **`gaugeCritical_iff_balanced`** — `le:moments` value vanishes for all `a` ⟺ `∀ j, G_j = 0`
  by trace-pairing nondegeneracy (`Matrix.ext_iff_trace_mul_left`, tested with `Pi.single`),
  combined with `balanced_iff_moment_zero`. Defined from derivatives, not by definition.

**Key technique (the instance diamond AGENTS.md flagged).** `Matrix` has two non-defeq
topologies (default Pi vs. Frobenius). Resolution: never ascribe a matrix-valued
`HasDerivAt`; build them as inferred terms under `open scoped Norms.Frobenius` and land in
ℝ via `traceCLM`/`transCLM` composition (`HasFDerivAt.comp_hasDerivAt`). The exported
lemmas are ℝ-valued, hence diamond-free and usable outside the Frobenius section. A bonus
simplification: the per-layer gauge curve is **uniform** across indices
(`gaugeL/gaugeR⁻¹` along the exp curve `= exp(t • snoc/cons` generator`)`), so no per-index
case split in the derivative. Full lessons in `AGENTS.md`.

**Verified.** `lake build` (green), `bash scripts/no_sorry.sh` (green),
`#print axioms Project.main` (no custom axioms).

---

## Session 2026-06-23 - Full v1 architecture compiles (breadth-first skeleton)

**Done.** All five v1 modules now exist and `lake build` is green end-to-end, with
exactly **three `sorry`s** marking the genuinely-hard math (so `no_sorry.sh` is
intentionally red until the second pass):
- `Project/MomentMap.lean`: `moment`, `balanced_iff_moment_zero` (proved),
  `gaugeExp` (via `Matrix.isUnit_exp`), `GaugeCritical` (concrete `HasDerivAt`),
  `gaugeCurve_mem_fiber` (proved). `minimizer_imp_gaugeCritical` and
  `gaugeCritical_iff_balanced` stated correctly, **sorry** (task #8).
- `Project/KempfNess.lean`: `KempfNessHyp` — the orbit-level KN 0.1(a) interface
  (`critical_imp_min_on_orbit`), hypothesis-bundle form, full Slodowy-provenance
  docstring. **No sorry.**
- `Project/Main.lean`: `main_regularizerSq` and `main` (`thm:intro`/`eq:variation1`,
  squared then unsquared via the Basic bridge). The two-inclusion proofs are
  **real and complete** (`⊆` via `minimizer_imp_gaugeCritical` +
  `gaugeCritical_iff_balanced`; `⊇` via `kn.critical_imp_min_on_orbit` +
  `fiber_subset_orbit` + `IsMinOn.on_subset`; KN used once). **No sorry in Main.**
- `Project/GroupAction.lean`: added `fiber_subset_orbit` (**sorry**, task #7) and
  `fiber_eq_orbit` (proved from both directions).

**Architecture validated.** The headline theorem assembles end-to-end; the only
gaps are the 3 cited/hard lemmas. KN is invoked exactly once (`⊇`); the set
equality is SVD-free.

**Remaining (second pass).** Task #7 (`fiber_subset_orbit`), task #8 (`le:moments`
+ the two MomentMap bridges). Then task #2 (Aristotle/review).

---

## Session 2026-06-23 - Basic.lean + GroupAction core (verified)

**Done (sorry-free, `lake build` + `no_sorry.sh` green).**
- `Project/Basic.lean`: real DLN objects with the locked ascending `Fin (L+1)` /
  `Fin L` indexing - `Weights`, `endToEnd` (reversed list product), `fiber`,
  `Balanced` (castSucc/succ Gram form), `regularizerSq` (primary), `regularizer`
  (`sqrt`), `FullRank = IsUnit`, `argminOn`. Acceptance gate proved:
  `endToEnd_N2`, `balanced_N2`, `regularizerSq_N2`, `regularizerSq_nonneg`, and
  the squared/unsquared bridge `isMinOn_regularizerSq_iff_regularizer` /
  `argmin_regularizerSq_eq_argmin_regularizer`.
- `Project/GroupAction.lean` core: gauge action `eq:group-action1` encoded via
  `gaugeL = Fin.snoc A 1` / `gaugeR = Fin.cons 1 A` (identity-padded boundaries),
  `MulAction (Fin L → GL (Fin d) ℝ) (Weights d L)` instance, the telescoping
  helper `reverseProd_conjChain`, `endToEnd_smul` (action preserves end-to-end
  product), `orbit_subset_fiber` (easy direction), and the SVD-free base
  `trivialBase`/`trivialBase_mem_fiber`.
- Verified definitions against the primary source (`intro.tex`): the N=2 guards
  pin `endToEnd ![W₁,W₂] = W₂*W₁` and `Balanced ![W₁,W₂] ↔ W₁W₁ᵀ = W₂ᵀW₂`.

**Pending in GroupAction.** `fiber_subset_orbit` (`le:group-orbit`),
`fiber_eq_orbit`, and `O_d^L` regularizer invariance (deferred; not on the main
set-equality path).

**Note on sequencing.** Aristotle N=2 checks are a review-gate item (per
`CODEX.md`), satisfied here by the equivalent sorry-free Lean proofs; deferred to
the review step after the first pass, not run inline.

---

## Session 2026-06-22 - Added Agent Role Documents

**Done.**
- Added `CLAUDE.md` with Claude Code's implementation-engineer instructions,
  v1 design invariants, Aristotle workflow, and verification commands.
- Added `CODEX.md` with Codex's reviewer role, review checklist, and Aristotle
  review gate. This is the document intended for later rename/merge into agent
  instructions.
- Imported generic Lean helper docs/tools into `.claude/docs/lean4/` and
  `.claude/tools/lean4/`.
- Added `.codex/commands/critique.md` containing the hostile-review critique
  command adapted to this project.
- Removed `.claude/commands/critique.md`; adversarial critique is Codex-only.

**Verified.**
- `bash scripts/no_sorry.sh`.
- Checked that the Aristotle API key appears only in ignored local `.env`, not
  in tracked-style docs.

---

## Session 2026-06-22 - Aristotle Structure Critique Submitted

**Done.**
- Added a directory-submission path to `aristotle/check-aristotle.py`, including
  async API handling, task-status polling, and safe extraction of result
  archives.
- Submitted the Mathlib-backed structure critique packet
  `aristotle/aristotle-in/structure-critique/` as Aristotle job
  `c8adefc9-1a0b-44ae-a6b9-65b1a3fd9ab6`; it is still running.
- Submitted the dependency-free structure critique packet
  `aristotle/aristotle-in/structure-critique-minimal/` as Aristotle job
  `6407261e-2993-4b60-968c-13dff4cef0d9`; it completed and downloaded to
  `aristotle/aristotle-out/structure-critique-minimal_aristotle/`.

**Main Aristotle criticisms.**
- Split `fiber_eq_orbit` into `orbit_subset_fiber` and `fiber_subset_orbit`;
  only the hard `fiber_subset_orbit` direction is `le:group-orbit`, and it must
  carry `FullRank X` plus a base point/nonempty-fiber hypothesis.
- Promote the squared/unsquared regularizer argmin bridge to an explicit
  top-level obligation before claiming the paper's `eq:variation1`.
- Do not leave `minimizer_imp_critical` as an unconditional black-box field; it
  must expose differentiability, gauge curves staying in the fiber, and
  two-sided variation hypotheses.
- Ensure `critical_iff_balanced` is proved from an independent analytic
  definition of gauge criticality, not by defining criticality to be balanced.
- Make the real KN/Slodowy hypotheses visible enough that complex KN cannot be
  substituted silently.

**Verified.**
- `lake env lean aristotle/aristotle-in/structure-critique/Shape.lean`.
- `lake env lean aristotle/aristotle-in/structure-critique-minimal/Skeleton.lean`.
- `.venv/bin/python -m py_compile aristotle/check-aristotle.py`.

**Follow-up incorporated.**
- Updated `FORMALIZATION_PLAN.md` to incorporate the Aristotle critique:
  split `orbit_subset_fiber`/`fiber_subset_orbit`, promoted the
  squared/unsquared objective bridge, exposed the calculus hypotheses behind
  `minimizer_imp_gaugeCritical`, and tightened the real-KN interface guidance.

---

## Session 2026-06-22 - Installed Aristotle Locally

**Done.**
- Created a project-local `.venv` with Python 3.12.
- Installed `aristotlelib 2.1.0`, which provides `.venv/bin/aristotle`.
- Updated `aristotle/check-aristotle.py` for the installed Aristotle 2.x API
  (`Project.create_from_directory`, `Project.from_id`, `get_files`) instead of
  the older `prove-from-file` CLI shape.
- Added `.env.example`; real `.env` is ignored and should contain
  `ARISTOTLE_API_KEY` from `https://aristotle.harmonic.fun/dashboard/keys`.

**Verified.**
- `.venv/bin/aristotle --version` reports `aristotlelib 2.1.0`.
- `.venv/bin/python -c "import aristotlelib; print('aristotlelib ok')"`.
- `.venv/bin/python -m py_compile aristotle/check-aristotle.py`.
- `.venv/bin/python aristotle/check-aristotle.py` now fails only because
  `ARISTOTLE_API_KEY` is not set, which is the expected remaining blocker.

**Blocked.**
- Live Aristotle submission still requires the user's API key. Do not print or
  commit the key; put it in local `.env` or export `ARISTOTLE_API_KEY`.

---

## Session 2026-06-22 - Added Aristotle Workflow

**Done.**
- Added the local workflow without alerts, external chat-model consultation,
  auto-commit/push, CI/deploy checks, or visualization reporting.
- Added `.claude/commands/` for `babysit`, `plan`, `prove`,
  `submit-aristotle`, `check-aristotle`, `simplify`, `strengthen`, `log`,
  `cleanup`, and `aristotle-structure-critique`.
- Added `aristotle/` with a job ledger, input/output directories,
  `check-aristotle.py`, and `STRUCTURE_CRITIQUE.md`.
- Updated `.gitignore` for generated Aristotle Lean submissions/outputs and
  Python cache files.
- Recorded that live submission needs Aristotle API configuration.

**Verified.**
- `lake build`.
- `bash scripts/no_sorry.sh`.
- Initial `python3 aristotle/check-aristotle.py` reported missing
  `aristotlelib`; the later installation session replaced this with the
  project-local `.venv` workflow above.

**Scope honesty.**
- No Lean source changed.
- The first Aristotle-facing payload is a structure-critique plan; actual Lean
  submissions wait until `Project/Basic.lean` contains real definitions to test.

---

## Session 2026-06-22 - Locked V1 Scope

**Done.**
- Read the primary source around Theorem `thm:intro`, Eq. `eq:variation1`, and
  the definitions feeding the first target.
- Confirmed the v1 capstone is the real full-rank L2 theorem:
  `argmin_{W in fiber X} ||W||_2 = fiber X intersection balanced`.
- Recorded the source labels needed for `Project/Basic.lean`:
  `eq:balanced-intro1`, `eq:balanced-intro2`, `eq:ridge`,
  `eq:group-action1`, `le:group-orbit`, `thm:intro`, and `eq:variation1`.
- Updated `README.md` and `CRITICISMS.md` so the repository states the current
  Lean status and does not overclaim.

**Verified.**
- `lake build` green after the doc-only phase.
- `bash scripts/no_sorry.sh` green after the doc-only phase.

**Scope honesty.**
- Current Lean code contains no paper theorem yet, only `Project.placeholder`.
- The real case is intended to use Slodowy's real Kempf-Ness extension, as
  described in `papers/arXiv-2511.01137v2/kempf-ness.tex`; it has not been
  formalized or even stated yet.
