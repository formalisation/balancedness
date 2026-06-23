You are reviewing the proposed Lean proof strategy for a formalization of
Lindsey-Menon, "Regularization Implies balancedness in the deep linear network",
arXiv:2511.01137.

Read `PROOF_STRATEGY.md` and `Skeleton.lean`. `Skeleton.lean` is deliberately
dependency-free: it abstracts away matrices and Mathlib so you can critique the
proof structure rather than spend time building dependencies.

Write a non-empty adversarial critique to `structure-critique-response.md`.
Focus on whether the interfaces in `Skeleton.lean` are honest obligations for
the actual project, not merely on whether the abstract theorem is provable.

Mandatory issues to address:

- Does `fiber_eq_orbit` hide the source-paper step `le:group-orbit`, or is it a
  legitimate separate target?
- Does `critical_imp_min_on_orbit` correctly model only the KN/Slodowy 0.1(a)
  input, or does it smuggle in more?
- Is the `argmin subset balanced` direction really Kempf-Ness-free?
- Is the `balanced subset argmin` direction the only place Kempf-Ness is used?
- Is `minimizer_imp_critical` too strong as a black-box field, and what analytic
  hypotheses must be exposed in the real Lean theorem?
- What hypotheses are missing from the skeleton when mapped back to real DLNs
  (`FullRank X`, nonempty fiber/base point, gauge curve preserving the fiber,
  differentiability, real-vs-complex KN, squared regularizer)?
- Which obligations should be split before implementation starts?

If the abstract skeleton proves but the proposed Lean project would still be
mathematically dishonest, say so directly.
