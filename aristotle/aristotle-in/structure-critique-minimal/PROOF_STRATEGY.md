# Minimal Proof-Structure Packet

The real project targets Lindsey-Menon Theorem `thm:intro`, Eq.
`eq:variation1`, for real square full-rank deep linear networks:

```text
argmin_{W in fiber X} ||W||_2 = fiber X intersection balanced
```

Version 1 is conditional on one named orbit-level Kempf-Ness/Slodowy interface.
It does not formalize Kempf-Ness itself.

## Intended Real Lean Modules

1. `Basic.lean`: define weights indexed by `Fin (L+1)`, balanced equations
   indexed by `Fin L`, end-to-end product `W_N * ... * W_1`, fiber,
   `regularizerSq`, and the headline set equality. Prove `N = 2` audit lemmas
   to lock orientation.
2. `GroupAction.lean`: define the `GL_d(R)^L` gauge action and prove full-rank
   fibers are gauge orbits (`le:group-orbit`) using sequential gauge-solving,
   not SVD.
3. `MomentMap.lean`: define moments, compute the first variation of
   `regularizerSq` along gauge curves, and prove `GaugeCritical iff balanced`.
4. `KempfNess.lean`: state one orbit-level interface:
   gauge-critical points minimize the squared regularizer on their orbit.
5. `Main.lean`: prove the set equality by two inclusions.

## Intended Direction Split

- `argmin subset fiber intersection balanced`: minimizer on fiber implies
  `GaugeCritical` by elementary calculus; `GaugeCritical iff balanced` gives
  balancedness. This direction should not use Kempf-Ness.
- `fiber intersection balanced subset argmin`: balanced implies
  `GaugeCritical`; Kempf-Ness gives minimum on the orbit; `fiber_eq_orbit`
  transfers orbit-minimality back to fiber-minimality. This is the only KN use.

## Design Invariants

- KN interface must stay orbit-level, not fiber-level.
- Main theorem is proved for `regularizerSq`; the unsquared norm is a later
  monotonicity bridge.
- Main set equality is SVD-free.
- The real proof must cite Slodowy/real Kempf-Ness, not silently use complex KN.
- `fiber_eq_orbit` must require full rank and an actual base point in the fiber.
