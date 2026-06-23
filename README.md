# Balancedness

A Lean 4 + [Mathlib](https://github.com/leanprover-community/mathlib4)
formalization of Kathryn Lindsey and Govind Menon,
*Regularization Implies balancedness in the deep linear network*,
arXiv:2511.01137.

Primary source TeX is in [`papers/arXiv-2511.01137v2/`](papers/arXiv-2511.01137v2/).
The Kempf-Ness layer is guided by [`papers/kempf-ness.tex`](papers/kempf-ness.tex)
and [`papers/kempf-ness-proof-sketches.md`](papers/kempf-ness-proof-sketches.md).

## What Is Formalized

Current Lean state: **v1 is assembled, sorry-free, and axiom-clean.** The
capstone `Project.main` (and its smooth squared-objective form
`Project.main_regularizerSq`) builds end-to-end; `bash scripts/no_sorry.sh`
passes, and `#print axioms Project.main` reports only Lean's standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). It is an **honest conditional
theorem**: the only unproved mathematical input is the named, orbit-level
Kempf-Ness interface `Project.KempfNessHyp`, threaded as an explicit hypothesis
(not a Lean `axiom`). The repository does **not** yet prove Lindsey-Menon
unconditionally — discharging `KempfNessHyp` is Track B / post-v1.

| Result | Statement | Source ref | Lean |
| --- | --- | --- | --- |
| Real full-rank L2 balancedness theorem | `argmin_{W in fiber X} ||W||_2 = fiber X intersection balanced` for full-rank `X`, conditional on `KempfNessHyp` | Theorem `thm:intro`, Eq. `eq:variation1` | `Project.main` (sorry-free, axiom-clean) |
| Squared-objective form | same equality for the smooth `regularizerSq` objective, transported to `||·||_2` via the `sqrt` bridge | Eq. `eq:variation1` | `Project.main_regularizerSq` |
| Kempf-Ness interface | orbit-level `critical ⇒ min on orbit` (KN Theorem 0.1(a)), the single black-box input | `papers/kempf-ness.tex`, `thm:kn2 (1)` | `Project.KempfNessHyp` (explicit hypothesis) |

Source definitions to match in the first Lean module:

| Object | Informal statement | Source ref |
| --- | --- | --- |
| End-to-end product | `X = W_N W_{N-1} ... W_1` | Eq. `eq:balanced-intro1` |
| Fiber | solution set of the end-to-end equation over fixed `X` | discussion after Eq. `eq:balanced-intro1` |
| Balancedness | `W_k W_k^* = W_{k+1}^* W_{k+1}` for `1 <= k <= N-1` | Eq. `eq:balanced-intro2` |
| L2 regularizer | `||W||_2^2 = sum_k Tr(W_k^* W_k)` | Eq. `eq:ridge` |
| Gauge action | `(W_N A_{N-1}^{-1}, A_{N-1} W_{N-1} A_{N-2}^{-1}, ..., A_1 W_1)` | Eq. `eq:group-action1` |
| Full-rank fiber as orbit | a full-rank fiber equals a `GL_d(R)^L` gauge orbit, using an arbitrary/trivial base and sequential gauge solve, not the SVD center | Lemma `le:group-orbit` |

## Scope Honesty

Version 1 is real matrices, square width `d`, full-rank end-to-end matrix `X`,
and the L2/Frobenius regularizer only. It is an honest conditional theorem:
assuming the orbit-level `KempfNessHyp` interface, the DLN-specific Lean work
proves the balancedness set equality. The intended proof follows the paper:
full-rank fibers are real reductive group orbits, the norm is orthogonal-group
invariant, and the real Kempf-Ness/Slodowy minimization theorem identifies the
minimizers with the balanced locus. The SVD center is off the main theorem path
and belongs only to later nonemptiness/canonical-representative corollaries.

Not yet formalized: complex matrices, lower-rank fibers, Schatten `p`
regularizers, L1 regularization, regularizing flows, Kirwan-Ness flow,
learning-flow geometry, full affine GIT, and good quotient theory.

## Build

```sh
lake exe cache get   # download prebuilt Mathlib oleans, once
lake build
```

Check there are no proof gaps in Lean source:

```sh
bash scripts/no_sorry.sh
python3 scripts/check_example.py
```

## Layout

```text
Project.lean                       root module (imports all of the below)
Project/Basic.lean                 core DLN objects, conventions, N=2 gate, sqrt bridge
Project/GroupAction.lean           gauge action, orbit/fiber bridge (le:group-orbit)
Project/MomentMap.lean             moments, first variation (le:moments), critical ↔ balanced
Project/KempfNess.lean             the KempfNessHyp interface (single black-box input)
Project/Main.lean                  the headline theorem main / main_regularizerSq
papers/                            primary source, edited notes, background
scripts/no_sorry.sh                proof-gap / axiom gate
scripts/check_example.py           numerical sanity-check template
AGENTS.md                          project memory and proof workflow
FORMALIZATION_PLAN.md              high-level module plan
PROGRESS.md                        session log and next actions
CRITICISMS.md                      known honesty and correctness risks
```
