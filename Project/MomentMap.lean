import Project.GroupAction

/-!
# Moments, gauge-criticality, and the critical ↔ balanced bridge

Mirrors Lindsey-Menon `le:moments` and the moment remark `eq:moment-DLN`.

**Naming caveat.** Over `ℝ` the fiber need not be symplectic (the paper notes it may
not even be even-dimensional), so `moment` is a genuine *moment map* only over `ℂ`.
In the real v1 it is the **first-variation obstruction** of the squared regularizer;
the file name is kept for continuity with the paper, not to invoke symplectic
moment-map machinery (which Mathlib lacks anyway).

## Contents

* `moment` — the moments `G_j = W_j W_jᵀ - W_{j+1}ᵀ W_{j+1}` (Eq. `eq:def-G`).
* `balanced_iff_moment_zero` — `Balanced ↔ ∀ j, G_j = 0` (immediate).
* `gaugeExp` / `GaugeCritical` — the one-parameter gauge curve `t ↦ exp(t•a) • W`
  and the concrete (derivative-based, manifold-free) criticality predicate.
* `gaugeCurve_mem_fiber` — gauge curves stay in the fiber (curve-level
  `orbit_subset_fiber`).
* `minimizer_imp_gaugeCritical`, `gaugeCritical_iff_balanced` — the two bridges
  consumed by `Main`. **Proofs deferred to the second pass** (see the per-lemma
  notes): they rest on the first-variation value `le:moments`
  `d/dt|₀ regularizerSq(exp(t•a)•W) = ∑_j 2·Tr(G_jᵀ a_j)`, the two-sided
  first-order necessary condition, and nondegeneracy of the trace pairing
  `⟨A,B⟩ = Tr(AᵀB)`.
-/

open Matrix NormedSpace

namespace Project

variable {d L : ℕ}

/-- The moments `G_j = W_j W_jᵀ - W_{j+1}ᵀ W_{j+1}`, `j : Fin L` (Eq. `eq:def-G`,
real case `* = ᵀ`). In the ascending convention `W_j = W j.castSucc`,
`W_{j+1} = W j.succ`. Over `ℝ` this is the first-variation obstruction of the
regularizer, a true moment map only over `ℂ`. -/
def moment (W : Weights d L) (j : Fin L) : Matrix (Fin d) (Fin d) ℝ :=
  W j.castSucc * (W j.castSucc)ᵀ - (W j.succ)ᵀ * W j.succ

/-- Balancedness is the vanishing of all moments (`eq:balanced-intro2` ⇔ `G = 0`). -/
theorem balanced_iff_moment_zero (W : Weights d L) :
    Balanced W ↔ ∀ j, moment W j = 0 := by
  simp only [Balanced, moment, sub_eq_zero]

/-- The one-parameter gauge-curve generator: `gaugeExp t a` is the gauge group
element `exp(t • a_j)` in each layer (a `GL`-unit since the matrix exponential is
always invertible, `Matrix.isUnit_exp`). The curve `t ↦ gaugeExp t a • W` is the
DLN gauge curve through `W` in direction `a ∈ (gl_d)^L`. -/
noncomputable def gaugeExp (t : ℝ) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    Fin L → GL (Fin d) ℝ :=
  fun j => (Matrix.isUnit_exp (t • a j)).unit

/-- Gauge-criticality (concrete, no manifolds): the first variation of
`regularizerSq` vanishes along the gauge curve `t ↦ gaugeExp t a • W` in every
direction `a`. This is defined from the derivative, **independently** of
balancedness; `gaugeCritical_iff_balanced` is the nontrivial bridge. -/
def GaugeCritical (W : Weights d L) : Prop :=
  ∀ a : Fin L → Matrix (Fin d) (Fin d) ℝ,
    HasDerivAt (fun t : ℝ => regularizerSq (gaugeExp t a • W)) 0 0

/-- Gauge curves stay inside the fiber (curve-level `orbit_subset_fiber`): a real
dependency of the `argmin ⊆ balanced` direction, though not a Kempf-Ness input. -/
theorem gaugeCurve_mem_fiber {X : Matrix (Fin d) (Fin d) ℝ} {W : Weights d L}
    (hW : W ∈ fiber X) (t : ℝ) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    gaugeExp t a • W ∈ fiber X :=
  orbit_subset_fiber hW (MulAction.mem_orbit W (gaugeExp t a))

/-! ## First variation of the squared regularizer (`le:moments`)

This is v1's one genuine analytic step: differentiate `t ↦ regularizerSq
(gaugeExp t a • W)` at `0`.  Matrix-valued derivatives are taken under the
Frobenius `NormedRing`/`NormedAlgebra` (activated locally by
`open scoped Norms.Frobenius`).  Only **ℝ-valued** `HasDerivAt` statements escape
the Frobenius section, so the Frobenius topology never clashes with the default
matrix topology (`instTopologicalSpaceMatrix`): matrix-valued `HasDerivAt`s are
only ever built as inferred intermediate terms, never restated. -/

/-- Left gauge generator `(a_1, …, a_{N-1}, 0)`: the `t`-derivative direction of
the `gaugeL` family `t ↦ gaugeL (gaugeExp t a)`. -/
def leftGen (a : Fin L → Matrix (Fin d) (Fin d) ℝ) : Fin (L + 1) → Matrix (Fin d) (Fin d) ℝ :=
  Fin.snoc a 0

/-- Right gauge generator `(0, -a_1, …, -a_{N-1})`: the `t`-derivative direction of
the inverse `gaugeR` family `t ↦ (gaugeR (gaugeExp t a))⁻¹`. -/
def rightGen (a : Fin L → Matrix (Fin d) (Fin d) ℝ) : Fin (L + 1) → Matrix (Fin d) (Fin d) ℝ :=
  Fin.cons 0 (fun j => -a j)

@[simp] lemma leftGen_castSucc (a : Fin L → Matrix (Fin d) (Fin d) ℝ) (j : Fin L) :
    leftGen a j.castSucc = a j := by simp [leftGen, Fin.snoc_castSucc]
@[simp] lemma leftGen_last (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    leftGen a (Fin.last L) = 0 := by simp [leftGen, Fin.snoc_last]
@[simp] lemma rightGen_zero (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    rightGen a 0 = 0 := by simp [rightGen, Fin.cons_zero]
@[simp] lemma rightGen_succ (a : Fin L → Matrix (Fin d) (Fin d) ℝ) (j : Fin L) :
    rightGen a j.succ = -a j := by simp [rightGen, Fin.cons_succ]

section
open scoped Norms.Frobenius

/-- Trace as a continuous linear map (finite-dimensional, Frobenius norm). -/
noncomputable def traceCLM (d : ℕ) : Matrix (Fin d) (Fin d) ℝ →L[ℝ] ℝ :=
  (Matrix.traceLinearMap (Fin d) ℝ ℝ).toContinuousLinearMap

@[simp] lemma traceCLM_apply (M : Matrix (Fin d) (Fin d) ℝ) : traceCLM d M = M.trace := rfl

/-- Transpose as a continuous linear map (finite-dimensional, Frobenius norm). -/
noncomputable def transCLM (d : ℕ) :
    Matrix (Fin d) (Fin d) ℝ →L[ℝ] Matrix (Fin d) (Fin d) ℝ :=
  (Matrix.transposeLinearEquiv (Fin d) (Fin d) ℝ ℝ).toLinearMap.toContinuousLinearMap

@[simp] lemma transCLM_apply (M : Matrix (Fin d) (Fin d) ℝ) : transCLM d M = Mᵀ := rfl

/-- The single-layer first variation: `d/dt|₀ Tr((e^{tb} W e^{tc})ᵀ (e^{tb} W e^{tc}))`.
The matrix-exponential derivative `d/dt|₀ e^{t•x} = x` (`hasDerivAt_exp_smul_const`)
is chained through `*`, transpose and trace as Frobenius-continuous maps; the
conclusion is ℝ-valued, hence diamond-free. -/
lemma hasDerivAt_summand (b c W : Matrix (Fin d) (Fin d) ℝ) :
    HasDerivAt (fun t : ℝ =>
        ((exp (t • b) * W * exp (t • c))ᵀ * (exp (t • b) * W * exp (t • c))).trace)
      ((b * W + W * c)ᵀ * W + Wᵀ * (b * W + W * c)).trace 0 := by
  have hL := hasDerivAt_exp_smul_const (𝕂 := ℝ) b (0 : ℝ)
  have hR := hasDerivAt_exp_smul_const (𝕂 := ℝ) c (0 : ℝ)
  have hM := (hL.mul_const W).mul hR
  have hMT := ((transCLM d).hasFDerivAt).comp_hasDerivAt (0 : ℝ) hM
  have hP := hMT.mul hM
  have hTr := ((traceCLM d).hasFDerivAt).comp_hasDerivAt (0 : ℝ) hP
  simp only [Function.comp, transCLM_apply, Pi.mul_apply,
    zero_smul, exp_zero, one_mul, mul_one] at hTr
  exact hTr

/-- The coerced left gauge family along the exp curve is uniformly an exponential:
`gaugeL (gaugeExp t a) k = exp (t • leftGen a k)` (identity padding at the top
becomes `exp 0 = 1`). -/
lemma coe_gaugeL_gaugeExp (t : ℝ) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) (k : Fin (L + 1)) :
    (gaugeL (gaugeExp t a) k : Matrix (Fin d) (Fin d) ℝ) = exp (t • leftGen a k) := by
  refine Fin.lastCases ?_ (fun j => ?_) k
  · simp [gaugeL, Fin.snoc_last]
  · simp [gaugeL, Fin.snoc_castSucc, gaugeExp]

/-- The coerced inverse right gauge family along the exp curve is uniformly an
exponential: `(gaugeR (gaugeExp t a) k)⁻¹ = exp (t • rightGen a k)` (the inverse
of `e^{t•aⱼ}` is `e^{-t•aⱼ} = e^{t•(-aⱼ)}`, via `Matrix.exp_neg`). -/
lemma coe_gaugeR_gaugeExp_inv (t : ℝ) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) (k : Fin (L + 1)) :
    (((gaugeR (gaugeExp t a) k)⁻¹ : GL (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ)
      = exp (t • rightGen a k) := by
  refine Fin.cases ?_ (fun j => ?_) k
  · simp [gaugeR, Fin.cons_zero]
  · simp only [gaugeR, Fin.cons_succ, gaugeExp, rightGen_succ]
    rw [Matrix.coe_units_inv, IsUnit.unit_spec, ← Matrix.exp_neg, smul_neg]

end

/-- The per-layer first variations sum to the moment trace-pairing
`∑_j 2·Tr(a_j G_j)`: reindex the `Fin (L+1)` weight sum to the `Fin L` gauge sum
(`leftGen`/`rightGen` vanish at the boundary), then use cyclicity of the trace and
the symmetry `Tr(Xᵀ W) = Tr(Wᵀ X)`. Pure trace algebra, no analysis. -/
lemma sum_perSummand (W : Weights d L) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    (∑ k, ((leftGen a k * W k + W k * rightGen a k)ᵀ * W k
            + (W k)ᵀ * (leftGen a k * W k + W k * rightGen a k)).trace)
      = ∑ j, 2 * (a j * moment W j).trace := by
  have hkey : ∀ k : Fin (L + 1),
      ((leftGen a k * W k + W k * rightGen a k)ᵀ * W k
          + (W k)ᵀ * (leftGen a k * W k + W k * rightGen a k)).trace
        = 2 * ((W k)ᵀ * leftGen a k * W k).trace + 2 * ((W k)ᵀ * W k * rightGen a k).trace := by
    intro k
    have hT : ((leftGen a k * W k + W k * rightGen a k)ᵀ * W k).trace
        = ((W k)ᵀ * (leftGen a k * W k + W k * rightGen a k)).trace := by
      rw [← Matrix.trace_transpose ((leftGen a k * W k + W k * rightGen a k)ᵀ * W k),
          Matrix.transpose_mul, Matrix.transpose_transpose]
    rw [Matrix.trace_add, hT, ← two_mul, mul_add, Matrix.trace_add,
        ← mul_assoc, ← mul_assoc, mul_add]
  rw [Finset.sum_congr rfl (fun k _ => hkey k), Finset.sum_add_distrib,
      ← Finset.mul_sum, ← Finset.mul_sum,
      Fin.sum_univ_castSucc (f := fun k => ((W k)ᵀ * leftGen a k * W k).trace),
      Fin.sum_univ_succ (f := fun k => ((W k)ᵀ * W k * rightGen a k).trace)]
  simp only [leftGen_castSucc, leftGen_last, rightGen_zero, rightGen_succ,
    Matrix.mul_zero, Matrix.zero_mul, Matrix.trace_zero, add_zero, zero_add]
  rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro j _
  have e1 : ((W j.castSucc)ᵀ * a j * W j.castSucc).trace
      = (a j * (W j.castSucc * (W j.castSucc)ᵀ)).trace := by
    rw [Matrix.trace_mul_cycle, Matrix.trace_mul_comm]
  have e2 : ((W j.succ)ᵀ * W j.succ * (-a j)).trace
      = -(a j * ((W j.succ)ᵀ * W j.succ)).trace := by
    rw [Matrix.mul_neg, Matrix.trace_neg, Matrix.trace_mul_comm]
  rw [e1, e2, moment, mul_sub, Matrix.trace_sub]
  ring

/-- `le:moments`: the first variation of the squared regularizer along the gauge
curve `t ↦ gaugeExp t a • W` at `t = 0` is the moment trace-pairing
`∑_j 2·Tr(a_j G_j)`. This single computed-derivative lemma powers **both** MomentMap
bridges: differentiability for `minimizer_imp_gaugeCritical`, and the value for
`gaugeCritical_iff_balanced`. -/
theorem hasDerivAt_regularizerSq_gaugeExp (W : Weights d L)
    (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    HasDerivAt (fun t : ℝ => regularizerSq (gaugeExp t a • W))
      (∑ j, 2 * (a j * moment W j).trace) 0 := by
  have hfun : (fun t : ℝ => regularizerSq (gaugeExp t a • W))
      = (fun t : ℝ => ∑ k, ((exp (t • leftGen a k) * W k * exp (t • rightGen a k))ᵀ
            * (exp (t • leftGen a k) * W k * exp (t • rightGen a k))).trace) := by
    funext t
    unfold regularizerSq
    apply Finset.sum_congr rfl
    intro k _
    simp only [smul_apply, coe_gaugeL_gaugeExp, coe_gaugeR_gaugeExp_inv]
  have hfun2 : (fun t : ℝ => ∑ k, ((exp (t • leftGen a k) * W k * exp (t • rightGen a k))ᵀ
            * (exp (t • leftGen a k) * W k * exp (t • rightGen a k))).trace)
      = ∑ k, (fun t : ℝ => ((exp (t • leftGen a k) * W k * exp (t • rightGen a k))ᵀ
            * (exp (t • leftGen a k) * W k * exp (t • rightGen a k))).trace) := by
    funext t; simp only [Finset.sum_apply]
  rw [hfun, hfun2, ← sum_perSummand W a]
  exact HasDerivAt.sum (fun k (_ : k ∈ Finset.univ) =>
    hasDerivAt_summand (leftGen a k) (rightGen a k) (W k))

/-- The gauge curve through `W` is the identity at `t = 0`: `gaugeExp 0 a • W = W`. -/
lemma gaugeExp_zero_smul (W : Weights d L) (a : Fin L → Matrix (Fin d) (Fin d) ℝ) :
    gaugeExp (0 : ℝ) a • W = W := by
  funext k
  rw [smul_apply, coe_gaugeL_gaugeExp, coe_gaugeR_gaugeExp_inv]
  simp

/-- A fiber-minimizer of `regularizerSq` is gauge-critical.

Assembled (not a Kempf-Ness input) from: (i) `gaugeCurve_mem_fiber` — the gauge
curve `t ↦ gaugeExp t a • W` stays in `fiber X`, so `t = 0` is a global minimum of
`g t = regularizerSq (gaugeExp t a • W)` on `ℝ`; (ii) `le:moments`
(`hasDerivAt_regularizerSq_gaugeExp`) — `g` is differentiable at `0`; (iii) the
first-order necessary condition `IsLocalMin.hasDerivAt_eq_zero`. -/
theorem minimizer_imp_gaugeCritical {X : Matrix (Fin d) (Fin d) ℝ} {W : Weights d L}
    (hW : W ∈ fiber X) (hmin : IsMinOn regularizerSq (fiber X) W) :
    GaugeCritical W := by
  intro a
  have hd := hasDerivAt_regularizerSq_gaugeExp W a
  have hmin0 : IsMinOn (fun t : ℝ => regularizerSq (gaugeExp t a • W)) Set.univ 0 := by
    rw [isMinOn_iff]
    intro t _
    have hmem : gaugeExp t a • W ∈ fiber X := gaugeCurve_mem_fiber hW t a
    simp only [gaugeExp_zero_smul]
    exact (isMinOn_iff.mp hmin) _ hmem
  have hloc : IsLocalMin (fun t : ℝ => regularizerSq (gaugeExp t a • W)) 0 :=
    hmin0.isLocalMin Filter.univ_mem
  have hzero : (∑ j, 2 * (a j * moment W j).trace) = 0 := hloc.hasDerivAt_eq_zero hd
  rwa [hzero] at hd

/-- The critical-point bridge: gauge-criticality is exactly balancedness.

`le:moments` gives `d/dt|₀ regularizerSq (gaugeExp t a • W) = ∑_j 2·Tr(a_j G_j)`.
Vanishing for all `a` is equivalent to `∀ j, G_j = 0` by nondegeneracy of the real
trace pairing `⟨A, B⟩ = Tr(Aᵀ B)` (here `Matrix.ext_iff_trace_mul_left`, tested by
`a = Pi.single j x`); combine with `balanced_iff_moment_zero`. Defined from
derivatives, the bridge is **not** true by definition. -/
theorem gaugeCritical_iff_balanced (W : Weights d L) :
    GaugeCritical W ↔ Balanced W := by
  rw [balanced_iff_moment_zero]
  constructor
  · intro hcrit j₀
    have hval : ∀ a : Fin L → Matrix (Fin d) (Fin d) ℝ,
        (∑ j, 2 * (a j * moment W j).trace) = 0 := fun a =>
      (hasDerivAt_regularizerSq_gaugeExp W a).unique (hcrit a)
    rw [Matrix.ext_iff_trace_mul_left]
    intro x
    have hsum := hval (Pi.single j₀ x)
    rw [Fintype.sum_eq_single j₀ (fun j hj => by simp [Pi.single_eq_of_ne hj])] at hsum
    simp only [Pi.single_eq_same] at hsum
    simp only [Matrix.mul_zero, Matrix.trace_zero]
    linarith [hsum]
  · intro hbal a
    have hd := hasDerivAt_regularizerSq_gaugeExp W a
    have hz : (∑ j, 2 * (a j * moment W j).trace) = 0 := by
      apply Finset.sum_eq_zero
      intro j _
      rw [hbal j, Matrix.mul_zero, Matrix.trace_zero, mul_zero]
    rwa [hz] at hd

end Project
