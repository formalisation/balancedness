# Proposed Lean Structure Critique Payload

This is the first Aristotle-facing review payload for the balancedness project.

Status on 2026-06-22: `aristotlelib` and the `aristotle` CLI are installed in
the project-local `.venv`. Live submission is blocked until
`ARISTOTLE_API_KEY` is set from the dashboard. This file records the payload to
submit once credentials are available.

## What Aristotle Can Check

Aristotle checks Lean proof obligations and can sometimes prove negations. It
cannot critique prose directly. Use this payload to guide extraction of small
standalone Lean files under `aristotle/aristotle-in/`.

## Proposed V1 Structure To Stress-Test

- Index by gauge layers `L`.
- Weights: `Fin (L+1) -> Matrix (Fin d) (Fin d) R`.
- Gauges and moments: `Fin L -> Matrix (Fin d) (Fin d) R`.
- Orientation: Lean index `0` is paper `W_1`, Lean index `L` is paper `W_N`.
- End-to-end product reverses the tuple: `W_N * ... * W_1`.
- Balancedness is adjacent Gram equality using `Fin.castSucc` / `Fin.succ`.
- Primary objective is `regularizerSq`, not the unsquared norm.
- Full rank is represented as invertibility / nonzero determinant.
- Criticality is concrete: derivative at zero of gauge curves.
- `KempfNessHyp` is orbit-level, not fiber-level.
- The main equality is SVD-free; SVD is only for later nonemptiness/canonical
  representative corollaries.

## First Lean Obligations To Extract

After `Project/Basic.lean` has real definitions, create standalone Aristotle
inputs for:

1. `endToEnd_N2`: with ascending tuple `![W1, W2]`, the product is `W2 * W1`.
2. `balanced_N2`: balancedness for `![W1, W2]` is exactly
   `W1 * W1.transpose = W2.transpose * W2`.
3. `regularizerSq_N2`: the squared regularizer is the two-term trace sum.
4. `regularizerSq_nonneg`: if needed for the later square-root monotonicity
   bridge.
5. A small lemma showing a fiber-level `KempfNessHyp` would make
   `le:group-orbit` unused, so the interface must remain orbit-level. This may
   be better enforced by code review than Aristotle.

## Reviewer Questions

- Does the chosen orientation make every adjacent equation match the source?
- Does any proposed definition accidentally reverse balancedness?
- Does any capstone statement use the unsquared norm before the monotonicity
  bridge exists?
- Does the `KempfNessHyp` interface still force `Main` to invoke
  `le:group-orbit`?
- Is SVD absent from the main set-equality dependency chain?
