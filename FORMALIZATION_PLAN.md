# Formalization Plan: Regularization Implies Balancedness

## Summary

This project formalizes Kathryn Lindsey and Govind Menon, *Regularization Implies
balancedness in the deep linear network*, arXiv:2511.01137, in Lean 4 + Mathlib.

The v1 target is the real, full-rank DLN theorem (Lindsey-Menon Theorem
`thm:intro`, Eq. `eq:variation1`):

```text
argmin_{W in fiber X} ||W||₂ = fiber X ∩ balanced
```

**Guiding principle.** The Lean proof should follow *Lindsey-Menon's* proof of
`thm:intro`, not reprove its inputs. Their proof is three steps: (1) match the
DLN to the Kempf-Ness dictionary, (2) verify full-rank fibers are group orbits
(`le:group-orbit`), (3) **cite** the Kempf-Ness theorem (real case: Slodowy's
extension). They do not prove Kempf-Ness; they invoke it. We mirror that exactly.

### The two tracks, and which one v1 is

- **Track A (v1):** Kempf-Ness is a single, clearly-named Lean *interface*
  (`Project/KempfNess.lean`) — a hypothesis bundle (preferred) or `axiom`. We
  prove all the DLN-specific content and assemble `thm:intro` *modulo* that one
  cited result, exactly as the paper does. This is the entire v1 scope.
- **Track B (post-v1):** discharge the KempfNess interface by formalizing the
  Kempf-Ness tower itself (special functions → tori → reductive case). This is a
  separate, much larger effort gated on Mathlib infrastructure that does not yet
  exist (see Risk Assessment). It is explicitly *not* v1.

Keeping these separate is both an engineering and an honesty decision: `Main`'s
logic does not change when the interface is later discharged, and the single
unproved input is one named declaration a human can audit against the paper.

### Exactly which Kempf-Ness statement v1 needs

Working out the set equality `eq:variation1` shows v1 consumes **only Kempf-Ness
Theorem 0.1(a)** (`critical point ⇒ global minimum`), specialized to the
regularizer on the orbit, and **only in the `⊇` direction**:

- `⊇` (`fiber X ∩ balanced ⊆ argmin`): `W` balanced ⇒ `W` gauge-critical
  (`le:moments`) ⇒ `W` is a global minimum on the orbit. The last implication is
  **KN 0.1(a)** — the one black-box use.
- `⊆` (`argmin ⊆ fiber X ∩ balanced`): `W ∈ argmin` ⇒ `W` gauge-critical
  (gauge curves stay in the fiber, `regularizerSq` is differentiable along them,
  and a two-sided one-variable minimum has zero derivative) ⇒ `W` balanced
  (`le:moments`). **No KN.**

The headline theorem does **not** need KN 0.1(b) (minimum set is a single
`K`-coset), 0.1(c) (transverse Hessian positivity), or Theorem 0.2 (stability) —
those are the Occam/uniqueness *interpretation* (Section `subsec:occam`), not the
set equality. The KempfNess interface is scoped to 0.1(a) alone. Any hypotheses
or context required by the real Slodowy/Richardson version of 0.1(a) must be
recorded in `KempfNessHyp`'s docstring or fields; do not replace that source by
the complex Kempf-Ness theorem silently.

The set equality itself constructs **no** point. Nonemptiness of
`fiber X ∩ balanced` is a separate (non-vacuity) corollary built from an explicit
balanced representative (the center `C`, via SVD), **not** from the stability
theorem 0.2 — this is why 0.2 is deferrable and SVD stays off the main path.

### Aristotle structure-critique adjustments

The first Aristotle critique of the proposed proof structure flagged a real
formalization hazard: the abstract assembly theorem can look clean while hiding
the hard mathematical obligations in opaque fields. The plan below incorporates
the following corrections as design requirements:

- Split the orbit bridge. `orbit_subset_fiber` is the easy product-invariance
  lemma; `fiber_subset_orbit` is the hard Lindsey-Menon `le:group-orbit` theorem.
  Do not bundle them into an anonymous `fiber_eq_orbit` iff until both directions
  are separately named and proved with explicit hypotheses.
- Promote the squared/unsquared objective bridge to a first-class theorem. The
  project may prove the main equality first for `regularizerSq`, but it may not
  claim the paper's `eq:variation1` until the `sqrt`/nonnegativity argmin bridge
  is proved and used.
- Do not state `minimizer_imp_critical` as an unconditional black box. It must be
  assembled from differentiability of the gauge curve, the fact that gauge curves
  stay inside the fiber, and the two-sided first-order necessary condition.
- Define `GaugeCritical` independently from balancedness and prove
  `GaugeCritical ↔ balanced` by the explicit first-variation / trace-pairing
  calculation. Never make this bridge true by definition.
- Keep the KN interface orbit-level, but make the real-KN/Slodowy provenance and
  the DLN regularizer-as-KN-function specialization explicit enough that complex
  KN cannot be substituted silently.

## Key Sources

- Lindsey and Menon, *Regularization Implies balancedness in the deep linear
  network*, arXiv:2511.01137. Local source: `papers/arXiv-2511.01137v2/`.
  - `intro.tex` — `thm:intro`, the action `eq:group-action1`, the moments
    `eq:def-G`, the Occam reading `subsec:occam`.
  - `kempf-ness.tex` — the three-step application proof and the abstract KN
    statements (`thm:kn1`, `thm:kn2`); the real case cites Slodowy.
  - `reg-flow.tex` — `le:group-orbit` (fibers as orbits) and `le:moments`
    (first variation of the regularizer = the moments `G`).
- Kempf and Ness, *The length of vectors in representation spaces* (Track B only).
  - Edited source: `papers/kempf-ness.tex`; proof sketches:
    `papers/kempf-ness-proof-sketches.md`. These are the **complex** reductive
    case; the real DLN needs Slodowy's extension on top.
- Wallach, *Geometric Invariant Theory over the Real and Complex Numbers*.
  - §3.6.2 is the reference for the **real** SVD used by the in-progress SVD
    module. Extract only the needed section to TeX before relying on it (do not
    build statements from the unread PDF).

### Incoming dependency: the SVD module

A separate real-SVD module is being written (real case per Wallach §3.6.2). It is
a dependency, not part of this plan's modules, and is **off the main theorem
path**. The set equality `eq:variation1` is proved by two inclusions and needs no
constructed point. SVD / the balanced center `C` is used **only** for the optional
`fiber X ∩ balanced ≠ ∅` nonemptiness / canonical-representative corollary — not
for `le:group-orbit` (which uses the trivial base `(X, 1, …, 1)`) and not for the
equality. Treat its API as an interface; do not duplicate SVD work or gate `Main`
on it.

## Lean Module Structure

v1 builds the DLN-specific core plus the KempfNess interface, then assembles the
theorem. The Kempf-Ness tower is a separate, deferred section.

### `Project/Basic.lean` — objects, conventions, headline statement

Define the real DLN objects and **lock the indexing convention first** (this is
the first real design risk; every downstream proof depends on it):

- Parameterize by the number of gauge layers `L`, **not** depth `N`, to avoid
  truncated `Fin (N-1)` subtraction. Weights `W : Fin (L+1) → Matrix (Fin d)
  (Fin d) ℝ`; gauges and moments `A G : Fin L → ...`. (Depth `N = L + 1`; keep it
  as an abbrev so docstrings still say "depth N".)
- **Orientation (ascending, locked):** Lean index `i : Fin (L+1)` ↔ paper
  subscript `i+1`, so `W 0 = W₁` and `W L = W_N`. This makes increasing Lean index
  = increasing paper subscript, so `Fin.castSucc`/`Fin.succ` adjacency mirrors the
  paper's `k → k+1` (where ~all proof work lives) with no subtraction. Chosen so
  the *proof-bearing* index relations read like the paper; the cost is one
  `reverse` in the product (next bullet).
- End-to-end product `X = W_N ⋯ W_1` (`eq:balanced-intro1`): highest subscript is
  leftmost, so `endToEnd W = (List.ofFn W).reverse.prod`. The `N = 2` lemma below
  guards the order.
- Fiber predicate over a fixed `X`.
- Balancedness (`eq:balanced-intro2`): the `G_j = 0` form,
  `W_j W_jᵀ = W_{j+1}ᵀ W_{j+1}` for `j : Fin L` via `castSucc`/`succ`.
- **Squared regularizer is primary** (`eq:ridge`): `regularizerSq W = Σ_k
  Tr(W_kᵀ W_k)` (a polynomial in the entries — smooth, no `sqrt`). Prove the whole
  theorem first against `regularizerSq`. Also define the paper's unsquared
  objective `regularizer W = Real.sqrt (regularizerSq W)` (or the exact Mathlib
  norm expression once the tuple norm API is chosen). The paper's `‖W‖₂` theorem
  is recovered only after proving the explicit bridge
  `argmin_regularizerSq_iff_argmin_regularizer`: strict monotonicity of `sqrt` on
  `[0,∞)` plus `regularizerSq_nonneg`. Do **not** run first-variation proofs
  against the unsquared norm, and do **not** label the squared theorem itself as
  `eq:variation1`.
- Full rank = **invertibility** (`IsUnit X`, equivalently `det X ≠ 0`), not a
  general `Matrix.rank` predicate — square full-rank is exactly invertible and the
  orbit proof needs only invertible factors (see `GroupAction.lean`).
- The minimizer set as `{W ∈ fiber X | IsMinOn regularizerSq (fiber X) W}` and the
  squared-objective capstone for the real full-rank (invertible-`X`) case. The
  paper-objective capstone is a separate theorem obtained from the bridge above.

**Acceptance gate — real Lean declarations, not informal tests.** State and prove
small source-audit lemmas pinning the definitions to the paper at `N = 2`
(`L = 1`):

```text
-- ascending: index 0 = W₁, index 1 = W₂
endToEnd_N2      : endToEnd ![W₁, W₂] = W₂ * W₁
balanced_N2      : Balanced ![W₁, W₂] ↔ W₁ * W₁ᵀ = W₂ᵀ * W₂
regularizerSq_N2 : regularizerSq ![W₁, W₂] = Tr (W₁ᵀ * W₁) + Tr (W₂ᵀ * W₂)
regularizerSq_nonneg : 0 ≤ regularizerSq W
argmin_regularizerSq_iff_argmin_regularizer :
  argminOn regularizerSq (fiber X) = argminOn regularizer (fiber X)
```

(exact syntax depends on the encoding). These are machine-checked regression
guards against indexing/order mistakes — note the literal lists `W₁` then `W₂`
(ascending index) while the product is `W₂ * W₁`, exactly the paper's convention.
The last two lemmas are the honesty gate between the smooth squared theorem and
the unsquared paper statement.

### `Project/GroupAction.lean` — the DLN gauge action

Mirror Lindsey-Menon step (1) and `le:group-orbit`.

- The `GL_d(ℝ)^L` action (`eq:group-action1`):

  ```text
  A · W = (W_N A_{N-1}^{-1}, A_{N-1} W_{N-1} A_{N-2}^{-1}, ..., A_1 W_1)
  ```

  Register this as a real `MulAction ((GL d ℝ)^L) Weights` — the action axioms
  hold (`A·(B·W) = (AB)·W`, the index-shifted inverses cancel) — so `orbit base`
  is `MulAction.orbit` and Mathlib's group-action API applies.
- The action preserves the end-to-end product.
- The orthogonal subgroup `O_d^L` preserves `regularizerSq` (`eq:group-action2`)
  — this is the `K`-invariance KN requires.
- Split the orbit/fiber bridge into named directions:
  - `trivialBase_mem_fiber`: `fiber X` is nonempty without SVD; the trivial
    factorization `(X, 1, …, 1)` lies in it.
  - `orbit_subset_fiber`: if `W₀ ∈ fiber X`, then
    `MulAction.orbit ((GL d ℝ)^L) W₀ ⊆ fiber X`. This is the easy product
    invariance lemma, and it is also the fact needed when deriving criticality
    from a fiber minimizer along gauge curves.
  - `fiber_subset_orbit` (`le:group-orbit`): if `FullRank X` and
    `W₀ ∈ fiber X`, then `fiber X ⊆ MulAction.orbit ((GL d ℝ)^L) W₀`. This is the
    hard Lindsey-Menon orbit theorem.
  - `fiber_eq_orbit`: an iff/equality corollary only after the two directions are
    separately proved and named.
- **Prove `fiber_subset_orbit` by sequential gauge-solve, not SVD:** invertibility
  of `X` forces every factor invertible — `det X = ∏ det W_k ≠ 0` (determinant
  multiplicativity) makes each `W_k` a unit — so the gauge relating two fiber
  points is determined one factor at a time. No SVD, no `N`-th root.

### `Project/MomentMap.lean` — first variation and the critical-point bridge

This is the bridge that turns "the KN minimizer" into "balanced". Mirror
`le:moments` and the moment remark `eq:moment-DLN`.

- Moments (`eq:def-G`): `G_j = W_j W_jᵀ - W_{j+1}ᵀ W_{j+1}`, `j : Fin L`.
- `balanced W ↔ ∀ j, G_j = 0`. (Immediate from the definitions.)
- **Criticality, defined concretely (no manifolds):** along the one-parameter
  gauge curve `t ↦ gaugeExp t a • W`,

  ```text
  GaugeCritical W := ∀ a, HasDerivAt (fun t => regularizerSq (gaugeExp t a • W)) 0 0
  ```

  i.e. the first variation vanishes in every gauge direction `a ∈ (gl_d)^L`. This
  keeps v1 finite-dimensional; no premature tangent-space/manifold infrastructure.
  `GaugeCritical` must be defined from derivatives/gauge curves, **not** as an
  abbreviation for `balanced` or `∀ j, G_j = 0`.
- Gauge curves stay inside the fiber:

  ```text
  gaugeCurve_mem_fiber :
    W ∈ fiber X → ∀ t, gaugeExp t a • W ∈ fiber X
  ```

  This is the curve-level version of `orbit_subset_fiber`, and it is a real
  dependency of the `argmin ⊆ balanced` direction even though it is not a
  Kempf-Ness input.
- First-order necessary condition as a standalone calculus lemma:

  ```text
  isMinOn_hasDerivAt_zero_of_curve :
    IsMinOn regularizerSq (fiber X) W →
    (∀ t, curve t ∈ fiber X) →
    curve 0 = W →
    HasDerivAt (fun t => regularizerSq (curve t)) c 0 →
    c = 0
  ```

  Exact syntax will follow Mathlib's derivative API. The point is that
  `minimizer_imp_critical` is assembled from this lemma plus
  `gaugeCurve_mem_fiber` and the derivative computation; it is not a primitive
  unconditional interface field.
- `le:moments` is the explicit first-variation **value**:

  ```text
  HasDerivAt (fun t => regularizerSq (gaugeExp t a • W)) (∑_j 2 • Re Tr(G_jᵀ a_j)) 0
  ```

  (constant per the chosen normalization). This single computed-derivative lemma
  powers **both** directions of the proof (differentiability for `⊆`, the value
  for the bridge).
- Derived lemma, not an interface:

  ```text
  minimizer_imp_gaugeCritical :
    IsMinOn regularizerSq (fiber X) W → GaugeCritical W
  ```

  Its proof must visibly use the three ingredients above: gauge curves preserve
  the fiber, `regularizerSq` has the computed derivative along those curves, and
  a two-sided one-variable minimum has derivative zero.
- **Critical-point bridge:** `GaugeCritical W ↔ ∀ j, G_j = 0 ↔ balanced W`. The
  hard direction is nondegeneracy of the real trace pairing `⟨A,B⟩ = Re Tr(AᵀB)`
  (`Re Tr(G_jᵀ a_j) = 0 ∀ a_j ⇒ G_j = 0`). Finite-dimensional linear algebra —
  concrete and tractable, *not* the project's hardest step.
- **Concrete dependency to verify early:** the derivative at `0` of
  `t ↦ gaugeExp t a` (`d/dt|₀ exp(t•a) = a`). Confirm the Mathlib
  matrix-exponential API supports this before committing to the analytic form; it
  is v1's one genuine analytic step.

**Naming honesty:** over `ℝ` the fiber need not be symplectic (the paper notes it
may not even be even-dimensional), so `G` is a genuine *moment map* only over
`ℂ`. In the real v1, `G` is the first-variation obstruction of the regularizer.
Keep the file name but say this in the module docstring so the name is not
mistaken for symplectic-moment-map machinery (which Mathlib lacks anyway).

### `Project/KempfNess.lean` — the cited interface (Track A)

The single black-box input, scoped to exactly the real Kempf-Ness/Slodowy
`critical ⇒ minimum` theorem needed for the DLN regularizer. **State it at the
orbit level, not the fiber level**, so it does not silently absorb the paper's
orbit-verification work — `Main` must still invoke `fiber_subset_orbit`
(`le:group-orbit`) to connect `fiber X` to an orbit. **Prefer the hypothesis
form** so the capstone stays a real, axiom-free *conditional* theorem:

```text
structure KempfNessHyp where
  /-- KN 0.1(a), Slodowy real case: a gauge-critical point of `regularizerSq` on
      a `(GL d ℝ)^L` orbit is a global minimum on that orbit.  This is the real
      Richardson-Slodowy/Kempf-Ness input specialized to the DLN action and the
      squared Frobenius regularizer, not the complex Kempf-Ness theorem and not a
      theorem about arbitrary functions on arbitrary orbits.

      The docstring / field hypotheses must record every side condition required
      by the cited source theorem (real reductive group, maximal compact
      `O_d^L`, `K`-invariance, and the identification of `regularizerSq` with the
      relevant Kempf-Ness length function). If the cited theorem truly has no
      closed-orbit hypothesis for 0.1(a), say that explicitly here; do not infer
      it silently.  (Source: thm:kn2 (1) / Slodowy.) -/
  critical_imp_min_on_orbit :
    ∀ base W, W ∈ MulAction.orbit ((GL d ℝ)^L) base →
      GaugeCritical W → IsMinOn regularizerSq (MulAction.orbit ((GL d ℝ)^L) base) W
```

- The interface mentions **orbits and `GaugeCritical`** — exactly what Track B
  (real reductive KN) will eventually deliver — so it is honest about its content,
  and it leaves `fiber_subset_orbit` / `le:group-orbit` as visible Lean work in
  `Main`.
- The interface is specialized to the DLN action and `regularizerSq`; it must not
  be generalized to an opaque theorem about an arbitrary `score` on an arbitrary
  `orbit`, because that would make the real-vs-complex and KN-function
  hypotheses unauditable.
- `Main` takes `(kn : KempfNessHyp)` ⇒ `thm:intro` is a theorem with **no custom
  axioms** ("if Kempf-Ness, then balancedness").
- Lighter alternative for an unconditional statement: `axiom dln_kempf_ness :
  KempfNessHyp`; then `Main` carries exactly that one declared axiom (whitelist it
  in the gate).
- The docstring must cite `thm:kn2`/Slodowy and state plainly that this is the
  one result not proved in v1.

### `Project/Main.lean` — assemble `thm:intro`

First prove the squared-objective equality against `regularizerSq`; only then
derive the paper's unsquared objective equality via
`argmin_regularizerSq_iff_argmin_regularizer` (`Basic.lean`). Follow the
`⊆`/`⊇` skeleton verbatim so the Lean reads like the paper. Use the split orbit
lemmas, not an opaque all-purpose iff:

- Choose `W₀ ∈ fiber X` (usually `trivialBase_mem_fiber X`).
- `⊆`: `W ∈ argmin ⇒ GaugeCritical W` via
  `minimizer_imp_gaugeCritical`, whose proof visibly uses
  `gaugeCurve_mem_fiber` / `orbit_subset_fiber`, differentiability of
  `regularizerSq`, and the two-sided first-order condition. Then
  `GaugeCritical ⇒ balanced` (MomentMap bridge). **Does not use KN**, but it is
  not group-action-free.
- `⊇`: `W balanced ⇒ GaugeCritical W` (MomentMap bridge) `⇒ minimum on the orbit`
  (`kn.critical_imp_min_on_orbit`), then transport orbit-minimality to
  fiber-minimality using `fiber_subset_orbit` for arbitrary fiber competitors.
  **The only place the KN black box is used.**

So KN is invoked exactly once, in one direction — minimal reliance on the cited
input, maximal real Lean content. The set equality needs **no** constructed
balanced point, hence **no SVD**. A separate nonemptiness corollary
(`fiber X ∩ balanced ≠ ∅`) is what makes the result non-vacuous; it uses the SVD
center `C` and is deliberately off the main path (see below).

### Deferred (Track B): the Kempf-Ness tower

These discharge `KempfNessHyp`. They are **not** v1 and must not block `Main`.
Down-scoped to what 0.1(a) needs (no single-coset, no Hessian for v1).

- `Project/SpecialFunctions.lean` — Kempf-Ness §1: finite sums of exponentials of
  affine functions; convexity and strict convexity (Lemma `1.1`); nondegenerate
  case (Prop `1.2`); the affine-quotient reduction (Lemma `1.3`); Theorem `1.4`.
  Feasible in Mathlib (`ConvexOn`/`StrictConvexOn`, `convexOn_exp`); Lemma `1.3`'s
  affine quotient is the fiddly part.
- `Project/TorusKN.lean` — Kempf-Ness §2 (Lemmas `2.1`, `2.2`): torus weight-space
  decomposition and the length function as a special function. **Blocked:**
  Mathlib has no algebraic-torus character/weight-space decomposition of a
  representation. Realistically an interface/hypothesis until that exists.
- `Project/ReductiveKN.lean` — Kempf-Ness §3, **0.1(a) only**: `critical ⇒ min`.
  **Blocked:** no Cartan decomposition / symmetric space infrastructure in
  Mathlib. For the DLN group `GL_d(ℝ)^(N-1)` specifically, investigate the more
  elementary and more faithful route via **polar decomposition** (`g = k·exp(S)`,
  `S` symmetric, componentwise) plus convexity of `τ ↦ ‖exp(τS)·W‖₂²` along
  symmetric one-parameter subgroups (a sum of exponentials → `SpecialFunctions`).
  This replaces "general reductive Cartan" with a concrete decomposition of the
  actual group; the multi-factor cross-terms need checking before committing.

## Sequencing

The order front-loads the tractable, faithful core and isolates the blocked
tower at the end (the reverse of building the KN tower first).

1. **`Basic.lean`** — objects, lock the indexing convention, squared-objective
   capstone statement, unsquared objective definition, and the
   `regularizerSq`/`regularizer` argmin bridge; pass the `N = 2` and objective
   bridge acceptance gates.
2. **`GroupAction.lean`** — action, product preservation, `O_d` invariance, and
   the split orbit bridge: `orbit_subset_fiber`, `fiber_subset_orbit`
   (`le:group-orbit`) by sequential gauge-solve, then `fiber_eq_orbit` as a
   corollary.
3. **`MomentMap.lean`** — moments, `balanced ↔ G = 0`, `le:moments`, and the
   `critical ↔ balanced` bridge, plus the non-opaque
   `minimizer_imp_gaugeCritical` assembled from gauge-curve-in-fiber,
   differentiability, and the one-variable first-order condition.
4. **`KempfNess.lean`** — state `KempfNessHyp` (KN 0.1(a) specialized).
5. **`Main.lean`** — assemble the squared equality against the interface, then
   derive `thm:intro` / `eq:variation1` for the unsquared objective using the
   bridge from `Basic.lean`. *At this point v1 is complete: a faithful,
   honestly-scoped theorem modulo one cited result.*
6. **Track B (post-v1):** discharge `KempfNessHyp` via the down-scoped tower
   (`SpecialFunctions` → `TorusKN` → `ReductiveKN`/polar route), and add the
   Occam refinement (0.1(b)/(c)) if desired.
7. **Only after v1 is stable**, consider extensions: complex matrices, lower-rank
   fibers, Schatten `p` regularizers, L1, regularizing flows, Kirwan-Ness flow,
   learning-flow geometry.

## Risk Assessment

- **Low risk**
  - Basic DLN definitions and the (squared) Frobenius regularizer.
  - End-to-end product invariance, `orbit_subset_fiber`, and `O_d^L` norm
    invariance.
  - `balanced ↔ ∀ j, G_j = 0`.
  - `MulAction` instance and `det`-multiplicativity factor-invertibility.
  - Indexing: largely *defused* by the `Fin (L+1)`/`Fin L` parameterization;
    still pin it with the `N = 2` acceptance lemmas before downstream proofs.

- **Medium risk**
  - `argmin_regularizerSq_iff_argmin_regularizer`: should be standard
    monotonicity/nonnegativity, but it is the honesty bridge to the paper's
    unsquared statement and must be proved before claiming `eq:variation1`.
  - `fiber_subset_orbit` (`le:group-orbit`) via sequential gauge-solve.
  - `minimizer_imp_gaugeCritical`: not Kempf-Ness, but it depends on an in-fiber
    gauge curve, differentiability, and a two-sided first-order necessary
    condition. Do not hide these as an unconditional field.
  - `le:moments` (the first-variation **value**) — v1's one genuine analytic step:
    differentiate `t ↦ regularizerSq (gaugeExp t a • W)` at `0`. Gated on the
    Mathlib matrix-exponential derivative `d/dt|₀ exp(t•a) = a`; verify this API
    early. The downstream `critical ↔ balanced` bridge is then mechanical linear
    algebra (*downgraded* from the previous plan's "highest-risk bottleneck").

- **Off the main path (does not affect the set equality)**
  - Balanced-representative existence / nonemptiness corollary: depends on the
    in-progress SVD module and a matrix `N`-th root. If the SVD API slips, the
    headline equality is unaffected — only the non-vacuity corollary waits.

- **High / blocked (Track B only — do not gate v1 on these)**
  - `TorusKN`: no Mathlib algebraic-torus weight-space decomposition.
  - `ReductiveKN`: no Mathlib Cartan decomposition / symmetric-space machinery;
    pursue the polar-decomposition route for `GL_d(ℝ)^(N-1)`.
  - These are the genuine bottlenecks. v1 sidesteps them by the KempfNess
    interface; they are *not* v1 work.

- **Correctness watch-items**
  - Real vs. complex: the Kempf-Ness sources are the complex case; the real DLN
    needs Slodowy's extension. The `KempfNessHyp` docstring must say so, and
    Track B must not silently apply complex KN to `GL_d(ℝ)`.
  - `GaugeCritical` must be an independent derivative-based predicate. If it is
    definitionally balanced, the hard theorem has been hidden in the KN
    interface.
  - Avoid opaque interface records with fields like `∀ W, minimizer → critical`
    or `∀ W, fiber W ↔ orbit W`; those erase the hypotheses Aristotle flagged.

## Testing And Verification

- Start sessions with `lake build` to warm Mathlib; use the `lean-lsp-mcp`
  loop (`lean_goal`, `lean_diagnostic_messages`) as the inner loop (see
  `AGENTS.md`).
- After each module: `lake build` and `bash scripts/no_sorry.sh`.
- After `Basic.lean`: check the `N = 2` source-audit lemmas and the
  `regularizerSq`/`regularizer` argmin bridge. The squared theorem alone is not
  the paper theorem.
- After `GroupAction.lean`: verify the dependency graph distinguishes
  `orbit_subset_fiber` from `fiber_subset_orbit`; `Main` should use the hard
  direction only where transporting fiber competitors to the orbit.
- After `MomentMap.lean`: verify `GaugeCritical` unfolds to a derivative
  statement, not balancedness, and that `minimizer_imp_gaugeCritical` depends on
  the explicit calculus/gauge-curve lemmas.
- Numerical sanity checks (`scripts/check_example.py`) on small cases: `N = 2`,
  `d = 1, 2`; random invertible gauge transforms; compare `‖·‖₂` of a generic
  fiber point against the balanced representative.
- **Axiom accounting for the capstone.** With the **hypothesis** form of
  `KempfNessHyp`, `Main` must use no custom axioms and no `native_decide` — verify
  with `lean_verify` / `#print axioms`. If the **`axiom`** form is chosen instead,
  the gate is relaxed to "no axioms other than the one declared `dln_kempf_ness`
  interface (plus Lean's standard axioms)"; document that single exception
  explicitly so it cannot hide other gaps.

## Assumptions

- v1 formalizes the real, full-rank L2 theorem only, *modulo* the KempfNess
  interface (Track A). Discharging that interface is Track B / post-v1.
- The Lean proof of `thm:intro` follows Lindsey-Menon's three-step proof, citing
  Kempf-Ness as the paper does — not reproving it.
- All regime hypotheses (depth, width, full rank, membership) are carried
  explicitly, never hidden in definitions.
- "Obvious" structure lemmas are split when their directions have different
  mathematical content: especially orbit/fiber inclusion, minimizer-to-critical
  calculus, and squared/unsquared objective translation.
- The SVD module is an external dependency (real case per Wallach §3.6.2), used
  only for the balanced representative, and is not duplicated here.
- Specialized/interface declarations standing in for absent Mathlib GIT
  infrastructure are acceptable when clearly named, isolated, and cited.
