import Project.MomentMap

/-!
# The cited Kempf-Ness interface (Track A)

This is the **single black-box input** of v1, scoped to exactly the real
Kempf-Ness / Slodowy `critical ⇒ minimum` theorem (`thm:kn2 (1)`, i.e. KN
Theorem 0.1(a)), specialized to the DLN gauge action and the squared Frobenius
regularizer.

It is stated at the **orbit level** (`critical ⇒ min on MulAction.orbit base`), so
`Main` is still forced to invoke `fiber_subset_orbit` (`le:group-orbit`) to connect
`fiber X` to an orbit — the interface does not silently absorb Lindsey-Menon's
orbit-verification step. We use the **hypothesis-bundle** form so the capstone is an
honest axiom-free *conditional* theorem ("if Kempf-Ness, then balancedness").

This is the one result **not proved** in v1. Discharging it is Track B / post-v1
(a down-scoped Kempf-Ness tower; see `FORMALIZATION_PLAN.md`).
-/

open Matrix

namespace Project

/-- The real Kempf-Ness / Slodowy input (KN Theorem 0.1(a), `thm:kn2 (1)`),
specialized to the DLN: **a gauge-critical point of `regularizerSq` on a
`(GL_d ℝ)^L`-orbit is a global minimum of `regularizerSq` on that orbit.**

This is the *real* Richardson-Slodowy extension of Kempf-Ness applied to the DLN
action `eq:group-action1` and the squared Frobenius length `regularizerSq`, **not**
the complex Kempf-Ness theorem and **not** a statement about an arbitrary function
on an arbitrary orbit.

Side conditions of the cited source theorem that this specialization relies on
(recorded here so the complex theorem cannot be substituted silently):
* the acting group is the real reductive group `(GL_d ℝ)^L` with maximal compact
  subgroup `O_d^L`;
* the objective is `K`-invariant: `regularizerSq` is invariant under the `O_d^L`
  action (`eq:group-action2`), so it descends to the symmetric space;
* `regularizerSq` is identified with the Kempf-Ness length function for this
  representation.

For the headline set equality we need **only** part (a), and only this orbit-level
`critical ⇒ min` direction (KN 0.1(b)/(c) and Theorem 0.2 are the Occam/uniqueness
interpretation, not the set equality). -/
structure KempfNessHyp (d L : ℕ) : Prop where
  critical_imp_min_on_orbit :
    ∀ (base W : Weights d L),
      W ∈ MulAction.orbit (Fin L → GL (Fin d) ℝ) base →
      GaugeCritical W →
      IsMinOn regularizerSq (MulAction.orbit (Fin L → GL (Fin d) ℝ) base) W

end Project
