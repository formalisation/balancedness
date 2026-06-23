# Adversarial structure critique — Lindsey–Menon balancedness formalization plan

Reviewer scope: `PROOF_STRATEGY.md` + `Shape.lean`. I did **not** re-prove the
paper. I stress-tested the proposed module/interface shape for honesty,
circularity, scoping, and faithfulness. Verdict up front: **the assembly is
logically sound and non-circular, the Kempf–Ness field is scoped correctly, but
the plan is too weak as a project plan** — almost all mathematical content lives
in unconstrained interface fields, one headline-faithfulness obligation (the
norm bridge) is silently missing, and the most dangerous sign error (the
gauge-action ↔ balancedness orientation) has been *deferred out of the file that
is being reviewed*, so the skeleton cannot catch it.

A meta-point first: the skeleton compiling tells you only that the **types wire
together**. It certifies nothing mathematical, because every hard step is a
hypothesis field. Treat a green `Shape.lean` as a syntax check on the dependency
DAG, not as evidence the plan is correct.

> Environment note (not part of the math critique): the project as shipped does
> not build. The root `lean-toolchain` pins `v4.31.0` while the resolved Mathlib
> dependency is `v4.28.0`, so the Mathlib cache is rejected and Batteries/Aesop
> are recompiled against the wrong compiler (hence the `already declared` /
> missing-`.olean` cascade). This must be fixed (align `lean-toolchain` with the
> Mathlib the manifest actually resolves) before any real Lean work; otherwise
> reviewers cannot even elaborate `Shape.lean` in-tree.

---

## 1. Does `Shape.lean` hide a major paper step inside an interface field?

Yes — and not just one. This is the central weakness. Of the six fields, **three
are entire theorems of the paper**, and the "assembly" theorem is ~15 lines of
plumbing that proves nothing on its own:

- `fiber_eq_orbit` **is** Lindsey–Menon `le:group-orbit` (full-rank fiber is a
  single gauge orbit). This is a substantial DLN-specific argument
  (sequential gauge-solving + determinant multiplicativity). Packaging it as one
  field is fine as a *boundary*, but the skeleton creates the illusion that the
  main theorem is "almost done" when in fact this field alone is a multi-lemma
  development.
- `critical_iff_balanced` **is** the first-variation / moment-map computation
  (`le:moments`) — the analytic heart of the paper. Hidden in one `↔`.
- `minimizer_imp_critical` hides the entire elementary-calculus argument
  (admissible gauge curves are differentiable, stay in the fiber, two-sided, so
  an interior min forces a vanishing first variation).

So "does it hide a step" → it hides **essentially the whole paper**. That is
acceptable for a *dependency skeleton*, but the plan should be explicit that
`Shape.lean` is a contract, and that the real difficulty is 100% in the fields.
The danger is using a green skeleton as a progress signal.

**Stronger objection (under-constrained interface).** The fields are independent
`Prop`s with **no coherence axioms** tying them together. Nothing in
`ProofInterfaces` forces:

- `orbit` to be an actual `MulAction.orbit` of the gauge group (the strategy
  *says* "later this should be `MulAction.orbit`", but the structure does not
  enforce it);
- `GaugeCritical` to be genuine criticality *with respect to that same action*;
- `regularizerSq` to be invariant under the compact part of the action (needed
  for Kempf–Ness to even make sense).

Because of this, the structure admits instantiations that satisfy all six fields
without matching the paper. Example: take `GaugeCritical := balanced`. Then
`critical_iff_balanced` is trivially `Iff.rfl`, and the intended factorization
"minimizer → critical (calculus) → balanced (moments)" silently collapses:
`minimizer_imp_critical` becomes the raw claim "minimizer ⟹ balanced", i.e. one
full half of the theorem, with the moment-map step deleted. The skeleton would
still typecheck and the assembly would still go through. So the structure does
not *pin* the intended proof; it only records a sufficient set of implications.
A reviewer cannot tell from `Shape.lean` whether the eventual instantiation is
the paper's proof or a degenerate relabeling.

**Recommendation:** either add coherence fields (e.g. `orbit` is
`MulAction.orbit` of an explicitly given gauge action, `GaugeCritical W ↔
∀ curve, HasDerivAt (regularizerSq ∘ curve) 0 0`), or — better — make the gauge
action a *concrete definition* in `GroupAction.lean` and derive `orbit`,
`GaugeCritical` from it, rather than leaving them as free fields.

## 2. Is the assembly circular or does it assume the conclusion?

**No.** I traced both inclusions:

- `⊆`: `hW.1` gives `W ∈ fiberSet X`; `minimizer_imp_critical` then
  `critical_iff_balanced` give `balanced W`. No use of the target equality.
- `⊇`: from `balanced ∧ fiber`, `fiber_eq_orbit` lands `W` in `orbit W0`,
  `critical_iff_balanced` gives criticality, `critical_imp_min_on_orbit` (KN)
  gives min-on-orbit, and `fiber_eq_orbit` transports back. No use of the target
  equality.

The conclusion `argmin = fiber ∩ balanced` is never assumed by any field, and
`critical_imp_min_on_orbit` is an *orbit-level* statement, not a fiber-level
restatement of the goal. So the assembly is honest and acyclic. The only thing
to flag is the one in §1: the assembly is *thin*, so "non-circular" is a weak
form of correctness here.

## 3. Is the orbit-level Kempf–Ness field scoped correctly to KN 0.1(a), or does it absorb the fiber-as-orbit theorem?

**Scoped correctly.** `critical_imp_min_on_orbit` is quantified over
`orbit base` and concludes `argminOn ... (orbit base)`. It never mentions
`fiberSet` or `FullRank`, so it does **not** absorb `fiber_eq_orbit`
(`le:group-orbit`). The split is exactly right: KN 0.1(a) = "gauge-critical ⟹
global min on its group orbit"; the fiber↔orbit identification is a separate,
DLN-specific field. Good design, and it matches the paper's own division of
labor (prove the DLN reductions, cite KN/Slodowy).

Caveats that should be recorded so the field is not later quietly strengthened:

- The field claims min for **every** critical point in **every** orbit with **no
  FullRank hypothesis**. That is correct for KN 0.1(a) (it is orbit-intrinsic),
  but it means the *honesty* of the field depends entirely on `orbit` actually
  being a reductive-group orbit and `regularizerSq` being the Kempf–Ness/
  norm-square functional for that action. Since neither is enforced (see §1),
  the field is only "KN 0.1(a)" under the intended instantiation. As a free
  field it is strictly an assumption.
- KN 0.1(a) actually delivers more than min (the minima form a single maximal-
  compact orbit). The plan uses only the weak `critical ⟹ min` half, which is
  the right minimal cut — but when instantiating from a real KN theorem in
  `KempfNess.lean`, do not accidentally state the field as the full
  uniqueness/compactness package; keep it to the half you use.

## 4. Is the `⊆` direction really Kempf–Ness-free?

**In the assembly, yes.** `⊆` uses only `minimizer_imp_critical` and
`critical_iff_balanced`; neither is KN. And the field is *plausibly* KN-free as
it will be proved: minimizer-along-two-sided-differentiable-curves ⟹ vanishing
first variation is pure calculus, and the gauge curve stays in the fiber because
the action preserves `endToEnd` (an elementary fact, not KN). Note also that
`minimizer_imp_critical` correctly carries **no `FullRank` hypothesis** — first-
order stationarity does not need full rank — so it is faithful and not gratuitously
strong.

One adversarial check to keep honest at implementation time: "min on the fiber ⟹
gauge-critical" is only the calculus statement if `GaugeCritical` is defined as
stationarity along the *gauge* curves (the directions tangent to the fiber that
the action generates). If `GaugeCritical` were ever defined as full Euclidean
stationarity on the ambient space, the implication would be **false** (the
minimizer is constrained to the fiber, not a free critical point). So the
KN-freeness of `⊆` hinges on the (currently unfixed) definition of
`GaugeCritical`. Pin it.

## 5. Does the `⊇` direction use Kempf–Ness exactly once?

**Yes, exactly once.** `⊇` invokes `critical_imp_min_on_orbit` (the KN field) a
single time. It also uses `fiber_eq_orbit` twice (forward to place `W` in the
orbit, backward to transport the conclusion) and `critical_iff_balanced` once,
but those are not KN. This matches the stated intent ("Kempf–Ness used once;
`le:group-orbit` transports back").

Worth stating plainly: `⊇` therefore rests on **two** heavy inputs, KN *and* the
group-orbit theorem. The "uses KN once" headline is true but should not be read
as "⊇ is easy" — its other load-bearing input, `fiber_eq_orbit`, is itself one
of the paper's main lemmas.

## 6. Is the squared-regularizer-first strategy mathematically faithful?

**Conditionally, and the bridge is missing from the structure.** The strategy
minimizes `regularizerSq = Σ_k Tr(Wₖᵀ Wₖ) = Σ_k ‖Wₖ‖²_F` and claims to recover
the paper's `‖W‖₂` "by monotonicity of sqrt." This is valid **iff** the paper's
`eq:variation1` objective is the *joint Euclidean (Frobenius) norm of the weight
tuple*, `‖W‖₂ = √(Σ_k Tr(Wₖᵀ Wₖ))`. Then `argmin √f = argmin f` because `√` is
strictly monotone on `[0,∞)`, and the strategy is faithful.

Failure modes the plan must rule out by checking the source:

- If `‖W‖₂` is the **sum of Frobenius norms** `Σ_k ‖Wₖ‖_F` (not of squares),
  the sqrt bridge is **invalid**: `argmin Σ‖Wₖ‖²_F ≠ argmin Σ‖Wₖ‖_F` in general,
  because `Σ x_k²` and `Σ x_k` are not related by a single monotone scalar
  reparametrization. (Note balancedness forces all layer norms equal — from
  `WⱼWⱼᵀ = W_{j+1}ᵀW_{j+1}` one gets `Tr` equal, i.e. `‖Wⱼ‖²_F = ‖W_{j+1}‖²_F` —
  so the two objectives agree *at* balanced points, but the argmin equivalence is
  a statement over the *whole fiber*, where they need not agree.)
- If `‖·‖₂` denotes the **operator/spectral 2-norm** of the end-to-end matrix,
  the squared-first strategy is simply about a different functional and the
  bridge fails outright.

**Concrete missing obligation:** there is **no field/lemma bridging `regularizerSq`
to the paper's `‖W‖₂`.** As formalized, the "v1 theorem"
(`main_set_equality_skeleton`) is a statement about `regularizerSq` only; it is
**not** the statement of `eq:variation1` until a monotone-bridge lemma

```
argminOn regularizerSq (fiberSet X) = argminOn paperNorm (fiberSet X)
```

is added and proved (strict-mono of `√`). Until then the plan, while internally
consistent, does not yet formalize the paper's headline. Add this as an explicit
obligation and state precisely which norm `paperNorm` is, with a citation to
`eq:variation1`.

## 7. Does `Fin (L+1)` weights / `Fin L` balanced equations risk reversing the source equations?

**The counts and adjacency in `Shape.lean` are correct; the real reversal hazard
lives in the deferred `GroupAction.lean` and cannot be caught here.**

What is correct in the file:

- `endToEnd = (List.ofFn W).reverse.prod`. With `List.ofFn W = [W₀,…,W_L]`
  (paper `[W₁,…,W_N]`) and Mathlib's `List.prod [a,b,c] = a*b*c`, this is
  `W_L * … * W₀ = W_N ⋯ W₁`. Matches the paper's end-to-end map. ✓
- `balanced` ranges `j : Fin L` (exactly `L` equations for `L+1` weights = one
  per adjacent pair). ✓ Using `Fin.castSucc j` (index `j`) and `Fin.succ j`
  (index `j+1`) gives genuinely adjacent layers (`castSucc`/`succ` differ by 1).
  ✓ The written shape `Wⱼ Wⱼᵀ = W_{j+1}ᵀ W_{j+1}` is the standard DLN adjacency
  coupling output-Gram of layer `j` to input-Gram of layer `j+1`. ✓

Why this is nonetheless a live hazard: the **correctness of the orientation**
(`WⱼWⱼᵀ = W_{j+1}ᵀW_{j+1}` rather than the transposed `WⱼᵀWⱼ = W_{j+1}W_{j+1}ᵀ`)
is determined by the *gauge-action convention* — which internal node `gⱼ` sits at
and whether it acts on the left or right. For the action `Wⱼ ↦ gⱼWⱼ`,
`W_{j+1} ↦ W_{j+1}gⱼ⁻¹` (consistent with the rightmost-first product `W_N⋯W₁`),
the first variation of `Σ‖Wₖ‖²_F` gives moment `Gⱼ = WⱼWⱼᵀ − W_{j+1}ᵀW_{j+1}`,
so `critical ⟺ balanced` exactly matches the `balanced` in this file. But if
`GroupAction.lean` instead defines `Wⱼ ↦ Wⱼ gⱼ⁻¹`, `W_{j+1} ↦ gⱼ W_{j+1}`, or
places `gⱼ` at the wrong node, the moment flips to `WⱼᵀWⱼ = W_{j+1}W_{j+1}ᵀ`, and
then `critical_iff_balanced` becomes **false/unprovable against the `balanced`
defined here**. The skeleton cannot detect this because the action,
`GaugeCritical`, and the moment map are all abstract fields.

**Recommendations:**

- The two planned `N = 2` audit lemmas (`endToEnd_N2`, `balanced_N2`) are
  necessary but **insufficient**: they pin the product order and the balanced
  equation but not their *mutual consistency with the action*. Add a third audit:
  an `N = 2` lemma computing the first variation explicitly and checking the sign/
  transpose of `G₁` equals the LHS−RHS of `balanced_N2`. This is the only
  guard that catches an orientation flip.
- Fix the gauge-action convention **now** (node placement + left/right) in
  `PROOF_STRATEGY.md` and tie `balanced`'s orientation to it in a comment, so the
  later `MomentMap.lean` work cannot silently contradict the chosen `balanced`.

## 8. Which obligations should be split before implementation?

The current six fields are at wildly different granularity; the three "theorem"
fields must be decomposed. Suggested splits:

- **`fiber_eq_orbit` (`le:group-orbit`)** → at least:
  1. gauge action is a well-defined `MulAction` (group axioms);
  2. action preserves `endToEnd` (⇒ `orbit W0 ⊆ fiberSet X`);
  3. full-rank fibers are transitive under the gauge group via sequential
     gauge-solving + `det` multiplicativity (⇒ `fiberSet X ⊆ orbit W0`);
  4. combine into the set equality. (Note the two-inclusion shape; do **not**
     prove this monolithically.)

- **`critical_iff_balanced` (`le:moments`)** → :
  1. define moments `Gⱼ` concretely;
  2. first-variation formula: `d/dt regularizerSq(curveⱼ(t))|₀ = ⟨A, Gⱼ⟩`
     (a `HasDerivAt` statement per gauge direction);
  3. `GaugeCritical W ↔ ∀ j, Gⱼ W = 0`;
  4. `(∀ j, Gⱼ W = 0) ↔ balanced W` (this is where the §7 orientation is fixed).

- **`minimizer_imp_critical`** → :
  1. gauge curve through `W` is differentiable and lies in `fiberSet X` for all
     small `t` (two-sided);
  2. `regularizerSq ∘ curve` is differentiable;
  3. interior minimum ⇒ derivative `0` ⇒ `GaugeCritical`.

- **`critical_imp_min_on_orbit` (KN/Slodowy 0.1(a))** → :
  1. a clearly-labeled, citeable abstract KN statement (the only intended
     external input);
  2. a DLN→KN "dictionary": identify the gauge action with the relevant
     reductive-group representation, `regularizerSq` with the norm-square
     functional, and `Gⱼ` with the moment map — so the abstract theorem actually
     applies. This dictionary is where unsoundness would hide; isolate it.

- **New, currently absent obligations to add:**
  1. **Norm bridge** (§6): `argmin regularizerSq (fiber) = argmin paperNorm
     (fiber)` via strict monotonicity of `√`, plus a precise definition of
     `paperNorm` matching `eq:variation1`. Without this the project does not
     formalize the paper's headline.
  2. **Coherence constraints** (§1): make `orbit`/`GaugeCritical` derived from a
     concrete gauge action rather than free fields, or add fields asserting the
     identifications, so the interface cannot be satisfied by a degenerate
     relabeling.
  3. (Optional, for the nonemptiness/representative corollaries the strategy
     mentions) existence of a minimizer / nonemptiness of `fiber ∩ balanced`,
     kept SVD-isolated as planned.

---

## Summary judgment

- Logic of the assembly: **sound, acyclic, conclusion not assumed.** (§2)
- KN field scoping: **correct (orbit-level, does not absorb `le:group-orbit`).**
  (§3)
- `⊆` KN-free: **yes in the assembly**, contingent on `GaugeCritical` being the
  gauge-curve stationarity notion. (§4)
- `⊇` uses KN once: **yes**, but also leans on the equally-hard group-orbit
  field. (§5)
- Squared-first: **faithful only if `‖·‖₂` is the joint Frobenius norm, and the
  required sqrt-bridge lemma is missing from the structure.** (§6)
- Indexing: **correct as written in `Shape.lean`**, but the genuine reversal risk
  is the deferred gauge-action orientation, which the skeleton cannot catch;
  needs a first-variation `N=2` audit. (§7)
- Biggest weakness: **all content is in unconstrained free fields**, so the
  skeleton certifies only type-level wiring; tighten the interface and decompose
  the three theorem-fields before implementation. (§1, §8)
- Plus an out-of-band blocker: **the shipped project does not build**
  (toolchain ↔ Mathlib version mismatch); fix before any in-tree elaboration.
