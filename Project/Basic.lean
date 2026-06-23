import Mathlib

/-!
# Core DLN objects, conventions, and the headline statement

Core definitions for the Lean formalization of Kathryn Lindsey and Govind
Menon, *Regularization Implies balancedness in the deep linear network*,
arXiv:2511.01137 (local source `papers/arXiv-2511.01137v2/`).

This module introduces the real, full-rank Deep Linear Network (DLN) objects and
**locks the indexing convention**, on which every downstream proof depends.

## Indexing convention (locked)

We parameterize by the number of *gauge layers* `L`, not the depth `N`, to avoid
truncated `Fin (N-1)` subtraction.  Depth is `N = L + 1` (`Project.depth`).

* Weights `W : Fin (L+1) → Matrix (Fin d) (Fin d) ℝ` (`Project.Weights`).
* Gauges and moments are indexed by `Fin L`.
* **Orientation is ascending:** Lean index `i : Fin (L+1)` is paper subscript
  `i+1`, so `W 0 = W₁` and `W L = W_N`.  Then `Fin.castSucc`/`Fin.succ`
  adjacency mirrors the paper's `k → k+1`, where essentially all proof work
  lives, with no subtraction.

The cost of the ascending choice is a single `reverse` in the end-to-end product
(highest subscript is leftmost): `endToEnd W = (List.ofFn W).reverse.prod`.  The
`N = 2` acceptance lemmas at the bottom of this file are machine-checked
regression guards against tuple/product/adjacency reversal.

## Objects (with source labels)

* `endToEnd`  — `X = W_N ⋯ W_1`            (Eq. `eq:balanced-intro1`).
* `fiber X`   — the solution set of `endToEnd W = X`.
* `Balanced`  — `W_k W_kᵀ = W_{k+1}ᵀ W_{k+1}`  (Eq. `eq:balanced-intro2`).
* `regularizerSq` — `Σ_k Tr(W_kᵀ W_k)`     (Eq. `eq:ridge`); the **primary**,
  smooth (polynomial) objective.  All first-variation work runs against it.
* `regularizer`   — `√ regularizerSq`, the paper's unsquared `‖W‖₂`.
* `FullRank X`    — invertibility `IsUnit X` (square full-rank ⇔ invertible).

The headline theorem (Thm `thm:intro`, Eq. `eq:variation1`)
`argmin_{W ∈ fiber X} ‖W‖₂ = fiber X ∩ balanced` is assembled in
`Project/Main.lean` against the Kempf-Ness interface; here we fix the objects and
prove the acceptance gate, including the squared/unsquared `argmin` bridge that
licenses translating the smooth squared theorem to the paper's `‖·‖₂` statement.
-/

open scoped Matrix

namespace Project

variable {d L : ℕ}

/-- Depth `N = L + 1`; weights are indexed by `Fin N = Fin (L+1)`, gauges and
moments by `Fin L`. Kept as an abbreviation so docstrings may speak of depth `N`. -/
abbrev depth (L : ℕ) : ℕ := L + 1

/-- A DLN weight tuple of width `d` and `L` gauge layers (depth `N = L+1`):
`W : Fin (L+1) → Matrix (Fin d) (Fin d) ℝ`, ascending index (`W 0 = W₁`,
`W L = W_N`). -/
abbrev Weights (d L : ℕ) : Type := Fin (L + 1) → Matrix (Fin d) (Fin d) ℝ

/-- End-to-end matrix `X = W_N W_{N-1} ⋯ W_1` (Eq. `eq:balanced-intro1`).

With the ascending index convention `W 0 = W₁, …, W L = W_N`, the highest paper
subscript must come leftmost in the product, so we reverse the tuple before
taking the list product. The guard `endToEnd_N2` pins the order. -/
def endToEnd (W : Weights d L) : Matrix (Fin d) (Fin d) ℝ :=
  (List.ofFn W).reverse.prod

/-- The fiber over `X`: all weight tuples with end-to-end matrix `X`
(solution set of Eq. `eq:balanced-intro1`). -/
def fiber (X : Matrix (Fin d) (Fin d) ℝ) : Set (Weights d L) :=
  {W | endToEnd W = X}

/-- Balancedness (Eq. `eq:balanced-intro2`): adjacent Gram matrices agree,
`W_k W_kᵀ = W_{k+1}ᵀ W_{k+1}` for `1 ≤ k ≤ N-1`. In the ascending convention the
`Fin L` index `j` is paper `k = j+1`, with `W_k = W j.castSucc` and
`W_{k+1} = W j.succ`. Over `ℝ` the conjugate transpose `*` is the transpose. -/
def Balanced (W : Weights d L) : Prop :=
  ∀ j : Fin L, W j.castSucc * (W j.castSucc)ᵀ = (W j.succ)ᵀ * W j.succ

/-- The squared `L²` (ridge) regularizer `Σ_{k=1}^N Tr(W_kᵀ W_k)`
(Eq. `eq:ridge`). This is a polynomial in the entries — smooth, no `sqrt` — and
is the **primary** objective: all first-variation proofs run against it. -/
def regularizerSq (W : Weights d L) : ℝ :=
  ∑ k, ((W k)ᵀ * W k).trace

/-- The paper's unsquared `L²` regularizer `‖W‖₂ = √(Σ_k Tr(W_kᵀ W_k))`
(Eq. `eq:ridge`). The squared/unsquared `argmin` bridge below shows minimizing
this agrees with minimizing `regularizerSq`. -/
noncomputable def regularizer (W : Weights d L) : ℝ :=
  Real.sqrt (regularizerSq W)

/-- Full rank of the end-to-end matrix means invertibility (`IsUnit X`,
equivalently `det X ≠ 0`). Square full-rank is exactly invertible; the orbit
proof needs only invertible factors. -/
def FullRank (X : Matrix (Fin d) (Fin d) ℝ) : Prop := IsUnit X

/-- The set of minimizers of `f` over the set `s` (the points of `s` that attain
the minimum). The headline theorem identifies `argminOn ‖·‖₂ (fiber X)` with
`fiber X ∩ balanced` (Eq. `eq:variation1`). -/
def argminOn (f : Weights d L → ℝ) (s : Set (Weights d L)) : Set (Weights d L) :=
  {W | W ∈ s ∧ IsMinOn f s W}

/-! ## Acceptance gate (`N = 2`, i.e. `L = 1`) and the objective bridge

These are real Lean regression guards, not informal tests. Note the literal list
`![W₁, W₂]` (ascending index) while the product is `W₂ * W₁`: exactly the paper's
convention. -/

/-- Order guard for the end-to-end product at depth `N = 2`: ascending index
`![W₁, W₂]` (so `W 0 = W₁`, `W 1 = W₂`) maps to the product `W₂ * W₁`
(Eq. `eq:balanced-intro1`). -/
theorem endToEnd_N2 (W₁ W₂ : Matrix (Fin d) (Fin d) ℝ) :
    endToEnd ![W₁, W₂] = W₂ * W₁ := by
  simp [endToEnd, List.ofFn_succ, List.ofFn_zero]

/-- Adjacency guard for balancedness at depth `N = 2`: `![W₁, W₂]` is balanced iff
`W₁ W₁ᵀ = W₂ᵀ W₂` (Eq. `eq:balanced-intro2`). -/
theorem balanced_N2 (W₁ W₂ : Matrix (Fin d) (Fin d) ℝ) :
    Balanced ![W₁, W₂] ↔ W₁ * W₁ᵀ = W₂ᵀ * W₂ := by
  simp [Balanced, Fin.forall_fin_one]

/-- Value guard for the squared regularizer at depth `N = 2`:
`regularizerSq ![W₁, W₂] = Tr(W₁ᵀ W₁) + Tr(W₂ᵀ W₂)` (Eq. `eq:ridge`). -/
theorem regularizerSq_N2 (W₁ W₂ : Matrix (Fin d) (Fin d) ℝ) :
    regularizerSq ![W₁, W₂] = (W₁ᵀ * W₁).trace + (W₂ᵀ * W₂).trace := by
  simp [regularizerSq, Fin.sum_univ_two]

/-- The squared regularizer is nonnegative: each summand `Tr(W_kᵀ W_k)` is the
trace of a positive-semidefinite matrix. Honesty gate for the `√` bridge. -/
theorem regularizerSq_nonneg (W : Weights d L) : 0 ≤ regularizerSq W := by
  unfold regularizerSq
  refine Finset.sum_nonneg fun k _ => ?_
  have h := (Matrix.posSemidef_conjTranspose_mul_self (W k)).trace_nonneg
  rwa [Matrix.conjTranspose_eq_transpose_of_trivial] at h

/-- Pointwise squared/unsquared bridge: a point minimizes the squared regularizer
over `fiber X` iff it minimizes the paper's `‖·‖₂` over `fiber X`. Strict
monotonicity of `√` on `[0,∞)` together with `regularizerSq_nonneg`. -/
theorem isMinOn_regularizerSq_iff_regularizer
    (X : Matrix (Fin d) (Fin d) ℝ) (W : Weights d L) :
    IsMinOn regularizerSq (fiber X) W ↔ IsMinOn regularizer (fiber X) W := by
  simp only [isMinOn_iff, regularizer]
  exact forall_congr' fun y => imp_congr_right fun _ =>
    (Real.sqrt_le_sqrt_iff (regularizerSq_nonneg y)).symm

/-- **Objective bridge** (honesty gate): the `‖·‖₂` minimizers over `fiber X`
coincide with the squared-regularizer minimizers. This licenses proving the
headline equality first for the smooth `regularizerSq` and then transporting it
to the paper's unsquared `eq:variation1`. -/
theorem argmin_regularizerSq_eq_argmin_regularizer (X : Matrix (Fin d) (Fin d) ℝ) :
    argminOn regularizerSq (fiber X) = argminOn (L := L) regularizer (fiber X) := by
  ext W
  simp only [argminOn, Set.mem_setOf_eq, isMinOn_regularizerSq_iff_regularizer]

end Project
