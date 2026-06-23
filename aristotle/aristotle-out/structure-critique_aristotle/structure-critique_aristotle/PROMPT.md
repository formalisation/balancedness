You are reviewing the proposed Lean formalization structure for Kathryn Lindsey
and Govind Menon, "Regularization Implies balancedness in the deep linear
network", arXiv:2511.01137.

Read `PROOF_STRATEGY.md` and `Shape.lean`. Do not try to reprove the paper.
Instead, critique the Lean structure as an adversarial formalization reviewer.

Write a non-empty critique to `structure-critique-response.md`. Focus on:

1. Whether `Shape.lean` hides any major paper step inside an interface field.
2. Whether the proof assembly is circular or assumes the conclusion.
3. Whether the orbit-level `KempfNessHyp` is scoped correctly to KN 0.1(a), or
   whether it accidentally absorbs the full-rank fiber-as-orbit theorem.
4. Whether the `⊆` direction is really Kempf-Ness-free.
5. Whether the `⊇` direction uses Kempf-Ness exactly once.
6. Whether the squared-regularizer-first strategy is mathematically faithful.
7. Whether the indexing convention `Fin (L+1)` for weights and `Fin L` for
   balanced equations is likely to reverse the source equations.
8. Which Lean obligations should be split further before implementation.

If a statement is probably false or missing hypotheses, say so directly and
name the missing hypotheses. If the shape looks formally valid but too weak as a
project plan, critique that too.
