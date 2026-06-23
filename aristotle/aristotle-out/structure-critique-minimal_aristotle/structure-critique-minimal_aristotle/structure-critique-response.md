# Adversarial critique of `Skeleton.lean` as an honest obligation set

Scope: I take the skeleton at its word — it is meant to expose *proof-assembly
interfaces* so we can judge whether discharging those interfaces in the real
project would honestly deliver Lindsey–Menon `thm:intro` / `eq:variation1`. The
abstract theorem `main_set_equality_skeleton` does typecheck and prove. My claim
is that **a successful discharge of these fields, as literally stated, would not
constitute an honest proof of the paper's theorem.** Details below.

Throughout, "the assembly" = the proof term of `main_set_equality_skeleton`.

---

## 0. The headline result is not what the skeleton proves

`eq:variation1` is a statement about the **unsquared** operator/2-norm
`argmin ||W||_2`. The skeleton's final object is a single `score : Weights → Nat`
and `PROOF_STRATEGY.md` admits the real `score` is `regularizerSq`. The squared
↔ unsquared monotonicity bridge is:

- **absent from the skeleton entirely** (there is no interface field for it), and
- **non-trivial to state honestly**, because there are two inequivalent readings
  of "the regularizer": `Σ_i ||W_i||²` (sum of squared layer norms) versus
  `(Σ_i ||W_i||)²` or `||W||_2` of the tuple. `argmin f = argmin (φ∘f)` only when
  `φ` is *strictly* monotone on the relevant range, and that range must be pinned
  to `[0,∞)`. Squaring the *total* and summing the *squares* are different
  functions with, in general, different argmins.

Consequence: even if every field of `ProofInterfaces` were discharged perfectly,
the project would have proved a statement about `score = regularizerSq`, and
marketing that as `eq:variation1` (unsquared) would be dishonest until a
separate, explicit `regularizer_argmin_bridge` lemma is in scope. This bridge
must be promoted to a first-class obligation, not a footnote ("later monotonicity
bridge").

Worse, the use of `Nat` as the codomain of `score` deletes **all** analytic
content. Over `Nat` there is no notion of derivative, criticality, moment map,
or Kempf–Ness function. The abstraction therefore cannot witness the honesty of
the very fields whose honesty is in question; it reduces the theorem to
set-bookkeeping. That is legitimate *for critiquing assembly wiring*, but it must
not be mistaken for evidence that the fields are sound.

---

## 1. `fiber_eq_orbit` — conflates two lemmas, only one of which is `le:group-orbit`

`fiber_eq_orbit : ∀ W, fiber W ↔ orbit W` packs **two** mathematically distinct
facts into one biconditional:

- `orbit W → fiber W` (the gauge action preserves the end-to-end product; *easy*,
  pure algebra `W_N⋯W_1` invariance), and
- `fiber W → orbit W` (any two full-rank factorizations of the same product are
  gauge-equivalent; *hard*). **This second direction alone is `le:group-orbit`.**

Two honesty problems:

1. **The assembly only ever uses `.1` (`fiber → orbit`)** — on `W` and on an
   arbitrary fiber element `Y`. The `.mpr` (`orbit → fiber`) is never invoked.
   So the skeleton both (a) demands the *hard* direction as the active ingredient
   (good — that is genuinely `le:group-orbit`), and (b) silently asserts the easy
   direction as a free rider that does no work *here* but is exactly the lemma
   needed elsewhere (see §3). Bundling them as one iff hides that
   `minimizer_imp_critical` secretly depends on `orbit ⊆ fiber`.

2. **No hypotheses.** The field is `∀ W`. In the real project the statement is
   **false without `FullRank X` and without a chosen base point `W₀ ∈ fiber X`**:
   `orbit` only makes sense as "the orbit of `W₀`," and the claim "the whole
   fiber is a single orbit" requires full rank (rank-deficient products have
   factorizations in distinct `GL_d(ℝ)^L` orbits). The skeleton's free-floating
   `orbit` predicate, anchored to no base point, makes the iff vacuously
   shapeable and erases the nonempty-fiber obligation `∃ W₀, fiber W₀`. Note the
   assembly applies `(fiber_eq_orbit Y).1` to *arbitrary* `Y` in the fiber, which
   is exactly "the fiber is one orbit" — confirming this field carries the real
   content and therefore must carry the real hypotheses.

**Verdict:** `fiber_eq_orbit` does not *hide* `le:group-orbit` — its `.1`
direction *is* `le:group-orbit` and is honestly load-bearing. But the iff
packaging is dishonest in two ways: it smuggles the easy `orbit ⊆ fiber` lemma
under the same name, and it drops `FullRank X` / base-point existence. Split it.

---

## 2. `critical_imp_min_on_orbit` — faithful to KN(a) in shape, but it smuggles the entire analytic existence layer

`critical_imp_min_on_orbit : ∀ W, orbit W → gaugeCritical W → Argmin score orbit W`
is the right *shape* for Kempf–Ness/Slodowy 0.1(a): a critical point of the
Kempf–Ness function on an orbit is a global minimum on that orbit. It does **not**
over-reach into uniqueness/`K`-orbit-of-minima claims, which is appropriately
conservative for this direction.

What it *does* smuggle:

- **Existence/attainment for free.** `Argmin score orbit W` asserts a *global*
  minimum is attained at `W`. Real KN needs the orbit to be **closed** (or the
  function proper / bounded below and the relevant orbit the closed one), the
  group **reductive**, and the function to be **the** Kempf–Ness function of a
  *linear* action. None of this is exposed; the field hands attainment over with
  zero hypotheses.
- **Real vs complex KN is invisible.** Design invariant #4 ("cite Slodowy/real
  KN, not silently complex KN") is **unenforceable at this interface**. An
  opaque `∀ W, … → Argmin …` field cannot record whether it is discharged by
  classical complex KN (wrong here: the gauge group is `GL_d(ℝ)^L`, maximal
  compact `O(d)^L`, the setting is the real Richardson–Slodowy/Lauret theory) or
  by the correct real statement. The `Nat` codomain compounds this by hiding that
  we are even over `ℝ`. A reviewer cannot distinguish an honest discharge from a
  dishonest one by reading the field.
- **Definitional coherence of `gaugeCritical`.** KN(a) only applies if
  `gaugeCritical` means "gradient of the KN function vanishes" = "moment map
  vanishes." If `gaugeCritical` is instead *defined* as `balanced` (so that
  `critical_iff_balanced` is near-`rfl`), then `critical_imp_min_on_orbit`
  silently becomes "balanced ⇒ global min on orbit," i.e. it *is* the entire hard
  theorem, and the burden has merely been relabeled. The skeleton gives no way to
  audit which notion of criticality KN consumes versus which the first-variation
  bridge produces — these must be proved to coincide, not assumed by sharing a
  name.

**Verdict:** correct model of *which* KN clause is used, but it is a black box
that absorbs closedness, properness, reductivity, real-vs-complex, and the KN
function identity. Those must become explicit hypotheses of the real lemma.

---

## 3. Is `argmin ⊆ balanced` really Kempf–Ness-free? — Yes, but it is *not* "elementary calculus," and that mislabel is the dishonesty

Syntactically: the forward branch uses only `minimizer_imp_critical` and
`critical_iff_balanced.1`; neither is `critical_imp_min_on_orbit`. So the
direction is **KN-free**, as claimed. Good.

But `minimizer_imp_critical` is described as "elementary calculus: fiber
minimizer implies vanishing gauge derivative," and that description is false as
stated:

- To differentiate `score` along a gauge curve `t ↦ g(t)·W` (`g(0)=I`) and
  conclude the derivative vanishes at a fiber-minimizer, the curve **must stay in
  the fiber**. That is precisely `orbit ⊆ fiber` — the *easy half of
  `fiber_eq_orbit`/`le:group-orbit`* (§1). So the forward direction is KN-free
  but **not group-action-free**; it has an undeclared dependency on the gauge
  curve preserving the fiber.
- It needs a genuine **first-order necessary condition**: `score` differentiable
  along the curve (`ContDiff`/`HasDerivAt`), and **two-sided** admissible
  variations (the minimum is interior in the gauge directions, the orbit through
  `W` is a smooth submanifold). Over `Nat` none of this exists.

**Verdict:** KN-free, yes; "elementary calculus," no. The label hides a
dependency on the gauge-preserves-fiber lemma and on differentiability +
smooth-orbit + interior-variation hypotheses.

---

## 4. Is `balanced ⊆ argmin` the only place KN is used? — Yes at the abstract level; confirm `critical_iff_balanced` stays KN-free in the real build

Syntactically the backward branch is the only consumer of
`critical_imp_min_on_orbit`, so KN appears exactly once. That is honest **iff**
`critical_iff_balanced` is genuinely a moment-map first-variation computation and
not a relabeled KN result. The risk flagged in §2 (defining `gaugeCritical :=
balanced` so that the real content silently migrates into
`critical_imp_min_on_orbit`) is the way this invariant gets violated without any
change to the assembly. Guard it by giving `gaugeCritical` an *independent*
analytic definition (moment map of the gauge action) and proving
`critical_iff_balanced` by explicit first-variation of `regularizerSq`.

---

## 5. `minimizer_imp_critical` is too strong as a black-box field

`∀ W, Argmin score fiber W → gaugeCritical W`, unconditional, is dishonestly
strong. The real Lean lemma must expose at least:

- **Differentiability**: `regularizerSq` is `ContDiff`/`HasDerivAt` along the
  gauge curve `t ↦ g(t)·W`.
- **Admissible curve in the fiber**: existence of a smooth one-parameter gauge
  family with `g(0)=I` whose image lies in `fiber X` (the `orbit ⊆ fiber`
  dependency from §3), with derivative spanning the tangent to the orbit.
- **Two-sided / interior variation**: the orbit through `W` is a smooth
  submanifold, so the first-order condition is `d/dt|₀ = 0`, not a one-sided
  KKT inequality.
- **Base point / nonemptiness**: `W` is an actual point of a nonempty fiber.

Without these the implication is either vacuous (`Nat`) or false (a fiber
minimizer need not be "critical" in any sense if the gauge curve leaves the
fiber). It is the necessary-condition half of the variational characterization
and must be stated with its analytic hypotheses, not as a total function.

---

## 6. Hypotheses missing from the skeleton (mapped to real DLNs)

The `ProofInterfaces` record carries **no** side conditions; every field is
`∀ W`. Mapped back to real square full-rank DLNs the following are missing and
each one changes the obligations:

- **`FullRank X`**: required for `fiber_eq_orbit.1` (fiber = single orbit) and
  for KN's closed-orbit hypothesis. Absent ⇒ §1 field is false.
- **Nonempty fiber / chosen base point `W₀ ∈ fiber X`**: `orbit` is undefined
  without it; `Argmin` attainment presupposes a nonempty domain. Absent ⇒ `orbit`
  is unanchored and the iff is vacuous.
- **Gauge curve preserving the fiber (`orbit ⊆ fiber`)**: needed by
  `minimizer_imp_critical` (§3,§5) and by the orbit→fiber consistency of the KN
  conclusion. Hidden inside the iff in §1.
- **Differentiability / smoothness**: `ContDiff` of `regularizerSq`, smoothness
  of the orbit submanifold — needed for both the first-variation bridge and the
  first-order condition. Erased by the `Nat` codomain.
- **Real (not complex) Kempf–Ness**: gauge group `GL_d(ℝ)^L`, maximal compact
  `O(d)^L`, Slodowy/Richardson real KN with closed-orbit + properness. The opaque
  field cannot record this (§2); design invariant #4 is currently unenforceable.
- **Squared vs unsquared regularizer**: the `score`/`regularizerSq` vs `||W||_2`
  gap and the strict-monotonicity bridge with its `[0,∞)` range (§0). Absent from
  the record entirely.

---

## 7. Obligations to split before implementation starts

1. **`fiber_eq_orbit` → two lemmas.** `orbit_subset_fiber` (gauge invariance of
   the product; easy; consumed by `minimizer_imp_critical`) and
   `fiber_subset_orbit` = `le:group-orbit` (hard; `FullRank X` + base point +
   sequential gauge-solving, SVD-free). Only the latter should bear the
   `le:group-orbit` name. Carry `FullRank X` and `∃ W₀, fiber W₀` as explicit
   hypotheses/parameters.
2. **`minimizer_imp_critical` → three pieces.** (a) `ContDiff`/`HasDerivAt` of
   `regularizerSq` along gauge curves; (b) construction of an in-fiber gauge
   curve with prescribed tangent (uses `orbit_subset_fiber`); (c) the first-order
   necessary condition (two-sided variation ⇒ derivative `= 0`).
3. **`critical_iff_balanced` → an explicit moment-map identity** plus its two
   directions, with `gaugeCritical` *defined independently* (moment map vanishes)
   so it cannot silently absorb KN (§4).
4. **`critical_imp_min_on_orbit` → a clearly-cited real-KN lemma** with explicit
   closed-orbit / reductive / properness hypotheses and an explicit statement
   that `score` restricted to the orbit is the Kempf–Ness function (so the cited
   theorem is real KN/Slodowy, not complex KN).
5. **`regularizer_argmin_bridge`**: new top-level obligation relating
   `argmin regularizerSq` to `argmin ||W||_2` via strict monotonicity on
   `[0,∞)`, pinning down which regularizer (`Σ||W_i||²`) is meant.
6. **Base-point / nonemptiness existence** as a standalone `∃ W₀, fiber W₀`
   lemma feeding the `orbit` definition and `Argmin` attainment.

---

## 8. Direct verdict

**The abstract skeleton proves, yet the proposed project as currently specified
would still be mathematically dishonest.** Three independent reasons:

1. It proves a statement about `score = regularizerSq`, but the paper's headline
   `eq:variation1` is about the unsquared norm, and the bridging lemma is neither
   present nor stated (§0, §7.5).
2. Every interface field is unconditional (`∀ W`) and `Nat`-valued, so as
   literally written the analytic fields are vacuous over `Nat` and false over
   `ℝ` without the dropped hypotheses (`FullRank X`, base point, gauge-preserves-
   fiber, differentiability). A real instantiation must reintroduce those
   hypotheses, which changes the assembly — so the current assembly is not a
   faithful template (§1, §5, §6).
3. The two soundness-critical design invariants — "KN stays orbit-level / real
   KN, not complex" and "criticality is the moment map, not a relabeled KN" —
   are **unenforceable through opaque fields**. The skeleton gives a reviewer no
   way to detect a discharge that uses complex KN or that hides the hard theorem
   inside `critical_imp_min_on_orbit` (§2, §4).

What *is* honest in the skeleton: the single-use of KN in the backward inclusion,
the KN-free forward inclusion, and the fact that the load-bearing `.1` of
`fiber_eq_orbit` genuinely is `le:group-orbit`. Fix the rest by splitting the
obligations in §7 and attaching the §6 hypotheses before any implementation
begins.
