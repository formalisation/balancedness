import Project.KempfNess

/-!
# Assembling Theorem `thm:intro` (Eq. `eq:variation1`)

The real, full-rank DLN balancedness theorem, conditional on the cited
`KempfNessHyp` (Track A):

```text
argmin_{W ∈ fiber X} ‖W‖₂ = fiber X ∩ balanced.
```

We first prove the equality for the smooth squared regularizer `regularizerSq`
(`main_regularizerSq`), then transport it to the paper's unsquared `‖·‖₂` objective
via the strict-monotonicity bridge `argmin_regularizerSq_eq_argmin_regularizer`
(`main`). The proof follows Lindsey-Menon's two-inclusion structure, and **Kempf-Ness
is invoked exactly once, in the `⊇` direction**:

* `⊆` (`argmin ⊆ balanced`): a fiber-minimizer is gauge-critical
  (`minimizer_imp_gaugeCritical`), hence balanced (`gaugeCritical_iff_balanced`).
  Uses gauge curves but **no Kempf-Ness**.
* `⊇` (`balanced ⊆ argmin`): a balanced point is gauge-critical, hence a minimum on
  its orbit (`kn.critical_imp_min_on_orbit`); transport to fiber-minimality via
  `fiber_subset_orbit` (`le:group-orbit`). **The only Kempf-Ness use.**

The set equality constructs no point and uses **no SVD**.
-/

open Matrix

namespace Project

variable {d L : ℕ}

/-- **Squared-objective form** of `thm:intro`/`eq:variation1`: for full-rank `X`,
the `regularizerSq`-minimizers over `fiber X` are exactly the balanced points,
conditional on `KempfNessHyp`. -/
theorem main_regularizerSq {X : Matrix (Fin d) (Fin d) ℝ} (hX : FullRank X)
    (kn : KempfNessHyp d L) :
    argminOn regularizerSq (fiber X) = fiber X ∩ {W : Weights d L | Balanced W} := by
  ext W
  simp only [argminOn, Set.mem_inter_iff, Set.mem_setOf_eq]
  constructor
  · -- ⊆ : minimizer ⇒ gauge-critical ⇒ balanced (no Kempf-Ness)
    rintro ⟨hWfib, hWmin⟩
    exact ⟨hWfib, (gaugeCritical_iff_balanced W).mp (minimizer_imp_gaugeCritical hWfib hWmin)⟩
  · -- ⊇ : balanced ⇒ gauge-critical ⇒ min on orbit (Kempf-Ness) ⇒ min on fiber
    rintro ⟨hWfib, hWbal⟩
    refine ⟨hWfib, ?_⟩
    have hcrit : GaugeCritical W := (gaugeCritical_iff_balanced W).mpr hWbal
    have hmin_orbit :=
      kn.critical_imp_min_on_orbit W W (MulAction.mem_orbit_self W) hcrit
    exact hmin_orbit.on_subset (fiber_subset_orbit hX hWfib)

/-- **Theorem `thm:intro` / Eq. `eq:variation1`** (paper's unsquared `L²` objective):
for full-rank `X`, the `‖·‖₂`-minimizers over `fiber X` are exactly the balanced
points, conditional on `KempfNessHyp`. Obtained from `main_regularizerSq` via the
squared/unsquared `argmin` bridge. -/
theorem main {X : Matrix (Fin d) (Fin d) ℝ} (hX : FullRank X) (kn : KempfNessHyp d L) :
    argminOn regularizer (fiber X) = fiber X ∩ {W : Weights d L | Balanced W} := by
  rw [← argmin_regularizerSq_eq_argmin_regularizer]
  exact main_regularizerSq hX kn

end Project
