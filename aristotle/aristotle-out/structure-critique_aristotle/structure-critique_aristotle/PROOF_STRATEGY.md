# Proposed Lean Proof Strategy

This is a structure-critique packet, not a finished formalization. Current Lean
source only contains `Project.placeholder`; the goal is to stress-test the
planned module/interface shape before implementation.

## Source Target

Formalize the real, square, full-rank case of Lindsey-Menon Theorem
`thm:intro`, Eq. `eq:variation1`:

```text
argmin_{W in fiber X} ||W||_2 = fiber X intersection balanced
```

The v1 theorem is conditional on one named Kempf-Ness interface, matching the
paper's proof: Lindsey-Menon prove the DLN-specific reductions and cite the real
Kempf-Ness/Slodowy theorem rather than proving it.

## Main Design Choices

- Parameterize by gauge-layer count `L`; weights have length `L+1`, gauges and
  moments have length `L`.
- Lean index `0` is paper `W_1`; Lean index `L` is paper `W_N`.
- The end-to-end product is reversed: `W_N * ... * W_1`.
- Balancedness is adjacent Gram equality:
  `W_j W_j^T = W_{j+1}^T W_{j+1}`.
- The primary objective is the squared Frobenius regularizer
  `sum_k Tr(W_k^T W_k)`. The unsquared norm is recovered later by monotonicity
  of `sqrt`, not used in the first-variation proof.
- Full rank is `det X != 0`.
- Criticality is concrete: derivative at zero of gauge curves.
- The main set equality is SVD-free. SVD is reserved for later nonemptiness or
  canonical representative corollaries.

## Planned Modules

1. `Project/Basic.lean`: definitions of weights, `endToEnd`, `fiber`,
   `balanced`, `regularizerSq`, minimizer set, headline skeleton. It must prove
   `N = 2` audit lemmas:
   - `endToEnd_N2`: `![W1, W2]` maps to `W2 * W1`;
   - `balanced_N2`: balancedness is `W1 W1^T = W2^T W2`;
   - `regularizerSq_N2`: the two-term trace sum.

2. `Project/GroupAction.lean`: define the `GL_d(R)^L` gauge action, prove it
   preserves `endToEnd`, prove orthogonal gauges preserve `regularizerSq`, and
   prove `le:group-orbit`: a full-rank fiber is one gauge orbit. This proof must
   use sequential gauge-solving and determinant multiplicativity, not SVD.

3. `Project/MomentMap.lean`: define moments `G_j`, prove
   `balanced iff G_j = 0`, compute the first variation of `regularizerSq` along
   gauge curves, and prove `GaugeCritical iff balanced`.

4. `Project/KempfNess.lean`: define `KempfNessHyp`, scoped only to real
   KN/Slodowy Theorem 0.1(a): gauge-critical points are global minima on their
   group orbit. This interface must be orbit-level, not fiber-level.

5. `Project/Main.lean`: assemble the two inclusions:
   - `argmin subset fiber intersection balanced`: minimizer implies gauge
     critical by elementary calculus, then balanced by `MomentMap`. This should
     not use Kempf-Ness.
   - `fiber intersection balanced subset argmin`: balanced implies gauge
     critical, then the Kempf-Ness interface gives global minimum on the orbit,
     and `le:group-orbit` transports this back to the fiber. This should use
     Kempf-Ness once.

## Critique Target

`Shape.lean` encodes the planned proof-assembly theorem abstractly. A valid
critique should say whether those fields are the right obligations, whether any
field is too strong or circular, and what should be split before real Lean work.
