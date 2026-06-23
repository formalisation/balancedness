import Project.Basic

/-!
# The DLN gauge action and the orbit/fiber bridge

This module mirrors Lindsey-Menon step (1) — matching the DLN to the Kempf-Ness
group-action dictionary — and Lemma `le:group-orbit`.

The gauge group is `(GL_d ℝ)^L = Fin L → GL (Fin d) ℝ` acting on `Weights d L`
by Eq. `eq:group-action1`:

```text
A · W = (W_N A_{N-1}⁻¹, A_{N-1} W_{N-1} A_{N-2}⁻¹, …, A_1 W_1).
```

## Encoding of the boundary gauges

In the ascending convention (`W 0 = W₁`, `W L = W_N`), component `i : Fin (L+1)`
(paper subscript `k = i+1`) transforms as `(A · W) i = A_{k} (W i) A_{k-1}⁻¹`,
with the boundary conventions `A_0 = A_N = 1` (no gauge past the ends). We realize
the two boundary-padded gauge families by `Fin.snoc`/`Fin.cons`:

* `gaugeL A = Fin.snoc A 1` — the *left* multiplier `A_k` (identity at the top
  index `L`, i.e. on `W_N`);
* `gaugeR A = Fin.cons 1 A` — the *right* multiplier `A_{k-1}` (identity at the
  bottom index `0`, i.e. on `W_1`).

so that `(A · W) i = gaugeL A i * (W i) * (gaugeR A i)⁻¹`. Both pads are monoid
homomorphisms in `A` (`gaugeL_one/mul`, `gaugeR_one/mul`), which is exactly what
makes the assignment a `MulAction`.
-/

open Matrix

namespace Project

variable {d L : ℕ}

/-- The left gauge multiplier family `A_k` (paper `eq:group-action1`), padded by
the identity at the top index `L` (no left gauge on `W_N`). -/
def gaugeL (A : Fin L → GL (Fin d) ℝ) : Fin (L + 1) → GL (Fin d) ℝ :=
  Fin.snoc A 1

/-- The right gauge multiplier family `A_{k-1}` (paper `eq:group-action1`), padded
by the identity at the bottom index `0` (no right gauge on `W_1`). -/
def gaugeR (A : Fin L → GL (Fin d) ℝ) : Fin (L + 1) → GL (Fin d) ℝ :=
  Fin.cons 1 A

@[simp] lemma gaugeL_one : gaugeL (1 : Fin L → GL (Fin d) ℝ) = 1 := by
  funext i; refine Fin.lastCases ?_ (fun j => ?_) i <;> simp [gaugeL]

@[simp] lemma gaugeR_one : gaugeR (1 : Fin L → GL (Fin d) ℝ) = 1 := by
  funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [gaugeR]

lemma gaugeL_mul (A B : Fin L → GL (Fin d) ℝ) :
    gaugeL (A * B) = gaugeL A * gaugeL B := by
  funext i; refine Fin.lastCases ?_ (fun j => ?_) i <;> simp [gaugeL, Pi.mul_apply]

lemma gaugeR_mul (A B : Fin L → GL (Fin d) ℝ) :
    gaugeR (A * B) = gaugeR A * gaugeR B := by
  funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [gaugeR, Pi.mul_apply]

/-- The DLN gauge action `eq:group-action1` of `(GL_d ℝ)^L` on weight tuples:
`(A · W) i = gaugeL A i · (W i) · (gaugeR A i)⁻¹`. -/
instance : SMul (Fin L → GL (Fin d) ℝ) (Weights d L) where
  smul A W := fun i => (gaugeL A i : Matrix (Fin d) (Fin d) ℝ) * W i * ((gaugeR A i)⁻¹ : GL (Fin d) ℝ)

@[simp] lemma smul_apply (A : Fin L → GL (Fin d) ℝ) (W : Weights d L) (i : Fin (L + 1)) :
    (A • W) i
      = (gaugeL A i : Matrix (Fin d) (Fin d) ℝ) * W i * ((gaugeR A i)⁻¹ : GL (Fin d) ℝ) :=
  rfl

/-- The gauge assignment is a group action: the boundary-padded gauges are monoid
homomorphisms in `A`, so identities and products transport correctly. This is the
Lean realization of "the DLN is a `(GL_d ℝ)^L`-space" used to invoke Kempf-Ness. -/
instance : MulAction (Fin L → GL (Fin d) ℝ) (Weights d L) where
  one_smul W := by
    funext i
    simp [gaugeL_one, gaugeR_one]
  mul_smul A B W := by
    funext i
    simp only [smul_apply, gaugeL_mul, gaugeR_mul, Pi.mul_apply, _root_.mul_inv_rev,
      Units.val_mul, mul_assoc]

/-! ## End-to-end invariance and the easy orbit inclusion -/

/-- Telescoping of a conjugation chain over vertex gauges `c : Fin (n+1) → GL`:
the reversed product of the conjugated edges `c (i+1) · P i · (c i)⁻¹` collapses to
`c (last) · (reversed product of P) · (c 0)⁻¹`. This is the algebraic heart of the
end-to-end invariance `eq:group-action1` (and of `le:group-orbit`). -/
lemma reverseProd_conjChain :
    ∀ {n : ℕ} (c : Fin (n + 1) → GL (Fin d) ℝ) (P : Fin n → Matrix (Fin d) (Fin d) ℝ),
      (List.ofFn fun i : Fin n =>
          (c i.succ : Matrix (Fin d) (Fin d) ℝ) * P i * ((c i.castSucc)⁻¹ : GL (Fin d) ℝ)).reverse.prod
        = (c (Fin.last n) : Matrix (Fin d) (Fin d) ℝ) * (List.ofFn P).reverse.prod
            * ((c 0)⁻¹ : GL (Fin d) ℝ) := by
  intro n
  induction n with
  | zero => intro c P; simp
  | succ m ih =>
      intro c P
      have h := ih (fun j => c j.succ) (fun j => P j.succ)
      simp only [Fin.succ_last, Fin.succ_zero_eq_one] at h
      simp only [List.ofFn_succ, List.reverse_cons, List.prod_append, List.prod_singleton,
        Fin.castSucc_succ, Fin.castSucc_zero, Fin.succ_zero_eq_one]
      rw [h]
      simp only [mul_assoc, Units.inv_mul_cancel_left]

/-- The boundary-padded *vertex* gauge family `(1, A_1, …, A_{N-1}, 1)` indexed by
`Fin (L+2)`. Edge `i` of the chain is conjugated by `gaugeV A i.succ` on the left
and `gaugeV A i.castSucc` on the right; the two endpoints are the identity. -/
def gaugeV (A : Fin L → GL (Fin d) ℝ) : Fin (L + 2) → GL (Fin d) ℝ :=
  Fin.cons 1 (gaugeL A)

@[simp] lemma gaugeV_succ (A : Fin L → GL (Fin d) ℝ) (i : Fin (L + 1)) :
    gaugeV A i.succ = gaugeL A i := by simp [gaugeV]

@[simp] lemma gaugeV_zero (A : Fin L → GL (Fin d) ℝ) : gaugeV A 0 = 1 := by simp [gaugeV]

@[simp] lemma gaugeV_last (A : Fin L → GL (Fin d) ℝ) : gaugeV A (Fin.last (L + 1)) = 1 := by
  unfold gaugeV
  rw [← Fin.succ_last, Fin.cons_succ]
  simp [gaugeL]

/-- The vertex gauge at a `castSucc` index recovers the right multiplier `gaugeR A`
— the adjacency `gaugeV A i.castSucc = gaugeV A (i-1).succ` that makes the chain
telescope. -/
@[simp] lemma gaugeV_castSucc (A : Fin L → GL (Fin d) ℝ) (i : Fin (L + 1)) :
    gaugeV A i.castSucc = gaugeR A i := by
  refine Fin.cases ?_ (fun j => ?_) i
  · simp [gaugeV, gaugeR, Fin.castSucc_zero]
  · simp [gaugeV, gaugeR, gaugeL, Fin.castSucc_succ]

/-- The gauge action preserves the end-to-end matrix (Eq. `eq:group-action1` leaves
`fiber X` invariant): `endToEnd (A · W) = endToEnd W`. -/
theorem endToEnd_smul (A : Fin L → GL (Fin d) ℝ) (W : Weights d L) :
    endToEnd (A • W) = endToEnd W := by
  have hfun : (A • W)
      = fun i => (gaugeL A i : Matrix (Fin d) (Fin d) ℝ) * W i * ((gaugeR A i)⁻¹ : GL (Fin d) ℝ) :=
    rfl
  have key := reverseProd_conjChain (gaugeV A) W
  simp only [gaugeV_succ, gaugeV_castSucc, gaugeV_zero, gaugeV_last,
    Units.val_one, inv_one, one_mul, mul_one] at key
  simp only [endToEnd]
  rw [hfun]
  exact key

/-- Easy direction of the orbit/fiber bridge: the gauge orbit of any fiber point
stays inside the fiber. This is product invariance, no full-rank needed. -/
theorem orbit_subset_fiber {X : Matrix (Fin d) (Fin d) ℝ} {W₀ : Weights d L}
    (hW₀ : W₀ ∈ fiber X) :
    MulAction.orbit (Fin L → GL (Fin d) ℝ) W₀ ⊆ fiber X := by
  rintro W ⟨A, rfl⟩
  show endToEnd (A • W₀) = X
  rw [endToEnd_smul]
  exact hW₀

/-! ## A trivial (SVD-free) base point of the fiber -/

/-- The trivial factorization `(X, 1, …, 1)` (paper's `W_N = X`, others identity).
Used as the SVD-free base point witnessing that `fiber X` is nonempty. -/
def trivialBase (X : Matrix (Fin d) (Fin d) ℝ) : Weights d L :=
  Fin.snoc (fun _ => 1) X

@[simp] theorem endToEnd_trivialBase (X : Matrix (Fin d) (Fin d) ℝ) :
    endToEnd (trivialBase (L := L) X) = X := by
  unfold endToEnd trivialBase
  rw [List.ofFn_succ']
  simp [Fin.snoc_castSucc, Fin.snoc_last, List.ofFn_const, List.prod_replicate]

/-- `fiber X` is nonempty without SVD: the trivial factorization lies in it. -/
theorem trivialBase_mem_fiber (X : Matrix (Fin d) (Fin d) ℝ) :
    trivialBase (L := L) X ∈ fiber X :=
  endToEnd_trivialBase X

/-! ## The hard direction (`le:group-orbit`)

`fiber_subset_orbit` is Lindsey-Menon's Lemma `le:group-orbit`: when `X` is full
rank, every point of `fiber X` is reachable from a base point by the gauge action.
The proof below is the SVD-free sequential gauge-solve: reduce to the trivial base
via `MulAction.orbit_eq_iff`; all factors are units (`det X = ∏ det (W i)`,
`factor_isUnit`); the solving gauge is the prefix product `A j = W_j ⋯ W_0`
(`preU`), mid indices telescope `A_i A_{i-1}⁻¹ = W_i`, and the top index closes by
`X = endToEnd W = W_L · A_{L-1}` (`mem_orbit_trivialBase`). -/
/-- Each factor of a full-rank end-to-end product is invertible
(`det X = ∏ det (W i)`), so a zero factor-determinant would force `det X = 0`. -/
theorem factor_isUnit {X : Matrix (Fin d) (Fin d) ℝ} {W : Weights d L}
    (hX : IsUnit X) (hW : endToEnd W = X) (i : Fin (L + 1)) : IsUnit (W i) := by
  rw [Matrix.isUnit_iff_isUnit_det, isUnit_iff_ne_zero]
  intro hWi
  have hdetX : X.det ≠ 0 := isUnit_iff_ne_zero.mp ((Matrix.isUnit_iff_isUnit_det X).mp hX)
  apply hdetX
  have hmap : (endToEnd W).det = ((List.ofFn W).reverse.map Matrix.det).prod := by
    rw [endToEnd]
    simpa [Matrix.coe_detMonoidHom] using Matrix.detMonoidHom.map_list_prod (List.ofFn W).reverse
  rw [← hW, hmap]
  apply List.prod_eq_zero_iff.mpr
  rw [List.mem_map]
  refine ⟨W i, ?_, hWi⟩
  rw [List.mem_reverse, List.mem_ofFn']
  exact ⟨i, rfl⟩

/-- Descending prefix product of units `Wu_{n-1} ⋯ Wu_0` (the length-`n` prefix).
This is the gauge that sequentially solves `A · trivialBase X = W`. -/
def preU (Wu : Fin (L + 1) → GL (Fin d) ℝ) (n : ℕ) : GL (Fin d) ℝ :=
  ((List.ofFn Wu).take n).reverse.prod

lemma preU_succ (Wu : Fin (L + 1) → GL (Fin d) ℝ) {n : ℕ} (h : n < L + 1) :
    preU Wu (n + 1) = Wu ⟨n, h⟩ * preU Wu n := by
  unfold preU
  have hlen : n < (List.ofFn Wu).length := by rw [List.length_ofFn]; exact h
  rw [List.take_add_one, List.getElem?_eq_getElem hlen]
  simp only [Option.toList_some, List.reverse_append, List.reverse_cons, List.reverse_nil,
    List.nil_append, List.singleton_append, List.prod_cons, List.getElem_ofFn]

/-- The full prefix product is the end-to-end matrix (the top consistency that
the SVD-free gauge-solve must satisfy). -/
lemma coe_preU_full {Wu : Fin (L + 1) → GL (Fin d) ℝ} {W : Weights d L}
    (hWu : ∀ i, ((Wu i : GL (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ) = W i) :
    ((preU Wu (L + 1) : GL (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ) = endToEnd W := by
  unfold preU endToEnd
  rw [List.take_of_length_le (by simp [List.length_ofFn])]
  have hcomp : (⇑(Units.coeHom (Matrix (Fin d) (Fin d) ℝ)) ∘ Wu) = W := funext hWu
  rw [← Units.coeHom_apply, map_list_prod, List.map_reverse, List.map_ofFn, hcomp]

/-- Core of `le:group-orbit`: every full-rank fiber point is reachable from the
trivial base by the gauge action. The solving gauge is the prefix product
`A j = W_j ⋯ W_0`; mid indices telescope `A_i A_{i-1}⁻¹ = W_i`, and the top index
closes by `X = endToEnd W = W_L · A_{L-1}`. SVD-free. -/
theorem mem_orbit_trivialBase {X : Matrix (Fin d) (Fin d) ℝ} (hX : FullRank X)
    {W : Weights d L} (hW : W ∈ fiber X) :
    W ∈ MulAction.orbit (Fin L → GL (Fin d) ℝ) (trivialBase X) := by
  have hWX : endToEnd W = X := hW
  have hu : ∀ i, IsUnit (W i) := fun i => factor_isUnit hX hWX i
  obtain ⟨Wu, hWu⟩ : ∃ Wu : Fin (L + 1) → GL (Fin d) ℝ,
      ∀ i, ((Wu i : GL (Fin d) ℝ) : Matrix (Fin d) (Fin d) ℝ) = W i :=
    ⟨fun i => (hu i).unit, fun i => (hu i).unit_spec⟩
  set A : Fin L → GL (Fin d) ℝ := fun j => preU Wu (j.val + 1) with hA
  have hgaugeR : ∀ i : Fin (L + 1), gaugeR A i = preU Wu i.val := by
    intro i
    refine Fin.cases ?_ (fun j => ?_) i
    · simp [gaugeR, preU]
    · simp [gaugeR, hA]
  rw [MulAction.mem_orbit_iff]
  refine ⟨A, ?_⟩
  funext i
  rw [smul_apply, hgaugeR]
  refine Fin.lastCases ?_ (fun j => ?_) i
  · -- i = last L : closes by `X = endToEnd W = W_L · A_{L-1}`
    have hLlt : L < L + 1 := Nat.lt_succ_self L
    rw [show gaugeL A (Fin.last L) = 1 from by simp [gaugeL],
        show trivialBase X (Fin.last L) = X from by simp [trivialBase],
        Fin.val_last, Units.val_one, one_mul, ← hWX, ← coe_preU_full hWu,
        preU_succ Wu hLlt, Units.val_mul, mul_assoc, Units.mul_inv, mul_one, hWu]
    exact congrArg W (Fin.ext rfl)
  · -- i = castSucc j : telescopes `A_j · A_{j-1}⁻¹ = W_j`
    have hjlt : (j : ℕ) < L + 1 := Nat.lt_succ_of_lt j.isLt
    rw [show gaugeL A (Fin.castSucc j) = preU Wu (j.val + 1) from by simp [gaugeL, hA],
        show trivialBase X (Fin.castSucc j) = 1 from by simp [trivialBase],
        Fin.val_castSucc, preU_succ Wu hjlt, Units.val_mul, mul_one, mul_assoc, Units.mul_inv,
        mul_one, hWu]
    exact congrArg W (Fin.ext rfl)

theorem fiber_subset_orbit {X : Matrix (Fin d) (Fin d) ℝ} (hX : FullRank X)
    {W₀ : Weights d L} (hW₀ : W₀ ∈ fiber X) :
    fiber X ⊆ MulAction.orbit (Fin L → GL (Fin d) ℝ) W₀ := by
  have heq : MulAction.orbit (Fin L → GL (Fin d) ℝ) W₀
      = MulAction.orbit (Fin L → GL (Fin d) ℝ) (trivialBase X) :=
    MulAction.orbit_eq_iff.mpr (mem_orbit_trivialBase hX hW₀)
  rw [heq]
  intro W hW
  exact mem_orbit_trivialBase hX hW

/-- Full-rank fibers are exactly gauge orbits (`le:group-orbit`), combining the
easy product invariance with the hard sequential gauge-solve. -/
theorem fiber_eq_orbit {X : Matrix (Fin d) (Fin d) ℝ} (hX : FullRank X)
    {W₀ : Weights d L} (hW₀ : W₀ ∈ fiber X) :
    fiber X = MulAction.orbit (Fin L → GL (Fin d) ℝ) W₀ :=
  Set.Subset.antisymm (fiber_subset_orbit hX hW₀) (orbit_subset_fiber hW₀)

end Project
