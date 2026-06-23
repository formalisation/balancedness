# Balancedness — project memory for Claude Code

Lean 4 + Mathlib formalization of Kathryn Lindsey and Govind Menon,
*Regularization Implies balancedness in the deep linear network*,
arXiv:2511.01137. Primary LaTeX source is in
`papers/arXiv-2511.01137v2/`; edited Kempf-Ness source and notes are
`papers/kempf-ness.tex` and `papers/kempf-ness-proof-sketches.md`.
Keep this file short; it is the single source of truth for accumulated lessons,
so they persist across machines. Update it (or run /memory) when a convention,
tactic, or decision stabilizes.

## Scope (what is formalized)
Current state (sorry-free, `lake build` + `no_sorry.sh` green):
- `Project/Basic.lean` — DLN objects with the locked ascending `Fin (L+1)`/`Fin L`
  indexing; `endToEnd`, `fiber`, `Balanced`, `regularizerSq`/`regularizer`,
  `FullRank`, `argminOn`; N=2 acceptance gate and the squared/unsquared `argmin`
  bridge proved.
- `Project/GroupAction.lean` — gauge action (`gaugeL`/`gaugeR`/`gaugeV` via
  `Fin.snoc`/`Fin.cons`), `MulAction` instance, telescope `reverseProd_conjChain`,
  `endToEnd_smul`, `orbit_subset_fiber`, `trivialBase`(`_mem_fiber`), and now the hard
  `fiber_subset_orbit` (`le:group-orbit`, SVD-free) + `fiber_eq_orbit` — sorry-free.
- `Project/MomentMap.lean` — moments, `balanced ↔ G = 0`, `gaugeExp`/`GaugeCritical`,
  and now the full analytic step **`le:moments`** (`hasDerivAt_regularizerSq_gaugeExp`:
  `d/dt|₀ regularizerSq(gaugeExp t a • W) = ∑_j 2·Tr(a_j G_j)`) plus both bridges
  `minimizer_imp_gaugeCritical` and `gaugeCritical_iff_balanced` — **sorry-free**.
  Also `hasDerivAt_regularizerSq_gaugeExp_N2`, the N=2 first-variation orientation
  guard (`2·Tr(a₀·(W₁W₁ᵀ − W₂ᵀW₂))`), companion to the `Basic.lean` N=2 gate.
- `Project/KempfNess.lean`, `Main.lean` — `Main.main` (`eq:variation1`) assembles against
  the `KempfNessHyp` interface. **v1 is complete and sorry-free** (`lake build` +
  `no_sorry.sh` green); `main` carries no custom axioms. `O_d^L` invariance still deferred
  (off the set-equality path); Track B (discharging `KempfNessHyp`) is post-v1.

v1 target (Track A — Kempf-Ness as a named interface; see `FORMALIZATION_PLAN.md`):
- `Project/Basic.lean` — real DLN definitions: matrix tuples (lock the `Fin N` /
  `Fin (N-1)` indexing), end-to-end product `X = W_N ... W_1`, fiber predicate,
  balancedness `W_k W_kᵀ = W_{k+1}ᵀ W_{k+1}`, Frobenius/L2 regularizer, and the
  real full-rank headline statement (Theorem `thm:intro`, Eq. `eq:variation1`).
- `Project/GroupAction.lean` — DLN `GL_d(ℝ)^(N-1)` action, product preservation,
  `O_d^(N-1)` norm invariance, and full-rank fibers as group orbits via the
  **SVD-free sequential gauge-solve** (Lemma `le:group-orbit`).
- `Project/MomentMap.lean` — moments `G_k`, `balanced ↔ ∀ k, G_k = 0`,
  `le:moments` (first variation), and the `critical ↔ balanced` bridge. Naming
  caveat: over `ℝ`, `G` is the first-variation obstruction, a true moment map
  only over `ℂ`.
- `Project/KempfNess.lean` — the one cited interface: KN Theorem 0.1(a)
  (`critical ⇒ minimum`) specialized to the DLN length function. Prefer the
  hypothesis-bundle form so `Main` is an axiom-free conditional theorem.
- `Project/Main.lean` — assemble the real full-rank theorem against the
  interface: `argmin_{W in fiber X} ||W||₂ = fiber X ∩ balanced`.

External dependency: a real-SVD module (Wallach §3.6.2) is being written
separately; used only for the balanced representative, not for `le:group-orbit`.

Track B (post-v1, discharges `KempfNess`; must not block `Main`):
- `Project/SpecialFunctions.lean` — Kempf-Ness §1 (Lemma `1.1`, Prop `1.2`,
  Lemma `1.3`, Theorem `1.4`).
- `Project/TorusKN.lean` — Kempf-Ness §2 (Lemmas `2.1`, `2.2`); blocked on absent
  Mathlib torus weight-space decomposition.
- `Project/ReductiveKN.lean` — Kempf-Ness §3, 0.1(a) only; blocked on absent
  Cartan/symmetric-space infrastructure — pursue the polar-decomposition route
  for `GL_d(ℝ)^(N-1)`.

**Deferred, not yet formalized:** complex matrices, lower-rank fibers, Schatten
`p` regularizers, L1 regularization, regularizing flows, Kirwan-Ness flow,
learning-flow geometry, and full affine GIT/good quotient theory. **Do not stub
these** — add them as real theorems when the time comes. An honest skeleton with
more `sorry`s beats a dishonest one with fewer (a `sorry` under a *correct*
statement documents what remains; a `sorry` under a *wrong* statement creates
false confidence).

## Conventions
- Cite the source equation/section label (e.g. `<label>`) in each theorem's
  docstring, so a human can audit the Lean against the paper.
- **Skeleton-first**: get a correct *statement* compiling before filling the
  proof. A wrong statement is worse than a visible gap.
- v1 is the real, full-rank DLN theorem only. Carry depth, width, and full-rank
  hypotheses explicitly instead of hiding regime assumptions in definitions.
- Matrices are over `ℝ` for v1. Align with Mathlib matrix APIs before inventing
  project-local linear algebra wrappers.
- Use the product convention from the paper: end-to-end map
  `X = W_N ... W_1`.
- Balancedness means adjacent Gram matrices agree:
  `W_k W_kᵀ = W_{k+1}ᵀ W_{k+1}`.
- The gauge action is by `GL_d(ℝ)^(N-1)`:
  `(W_N A_{N-1}^{-1}, A_{N-1} W_{N-1} A_{N-2}^{-1}, ..., A_1 W_1)`.

Implementation conventions (decided; see `FORMALIZATION_PLAN.md` for rationale):
- **Index by gauge layers `L`, not depth `N`:** weights `Fin (L+1)`, gauges and
  moments `Fin L`; adjacency via `Fin.castSucc`/`Fin.succ`. Avoid `Fin (N-1)`
  subtraction. Keep `N := L+1` as an abbrev for docstrings.
- **Orientation (ascending, locked):** Lean index `i` ↔ paper subscript `i+1`
  (`W 0 = W₁`, `W L = W_N`), so `castSucc`/`succ` mirror the paper's `k → k+1`.
  The product is the reversed fold (`X = W_N⋯W_1` = `(List.ofFn W).reverse.prod`);
  `endToEnd_N2 : endToEnd ![W₁, W₂] = W₂ * W₁` guards it.
- **Squared regularizer is primary:** prove against `regularizerSq W = Σ Tr(WₖᵀWₖ)`
  (smooth, no `sqrt`); recover the paper's `‖·‖₂` via a separate
  strict-monotonicity lemma. Never differentiate the unsquared norm.
- **Full rank = invertibility** (`IsUnit X` / `det X ≠ 0`), not `Matrix.rank`;
  derive factor-invertibility from `det X = ∏ det Wₖ`.
- **Gauge action as a real `MulAction ((GL d ℝ)^L)`**; use `MulAction.orbit`.
- **Criticality is concrete:** `GaugeCritical W := ∀ a, HasDerivAt (fun t =>
  regularizerSq (gaugeExp t a • W)) 0 0`. No manifold/tangent-space infrastructure
  in v1.
- **KN interface is orbit-level and used once** (`⊇` only); the set equality is
  SVD-free (trivial base `(X,1,…,1)`); SVD is only for the nonemptiness corollary.
- Use `papers/kempf-ness.tex` and `papers/kempf-ness-proof-sketches.md` for the
  Kempf-Ness proof structure (Track B only — needed when discharging the
  `KempfNess` interface, not for v1). Note these are the *complex* reductive
  case; the real DLN needs Slodowy's extension on top.
- Wallach's *Geometric invariant theory* is available only as large local
  background; §3.6.2 is the reference for the real SVD module. First extract only
  that section to TeX, keep the PDF and generated TeX ignored, then read the TeX
  rather than the PDF.

## Proof Workflow

**Skeleton correctness takes priority over filling in sorries.** A sorry with a correct statement is valuable (it documents what remains to prove); a sorry with a wrong statement is actively harmful (it creates false confidence and wasted work downstream). When auditing reveals incorrect lemma statements, fix them before working on other tractable sorries — even in other files. An honest skeleton with more sorries beats a dishonest one with fewer.

**Verify theorem statements against the source paper early.** Before building infrastructure, read the primary source to confirm: (1) single application or repeated/recursive? (2) essential tree structures or bookkeeping? (3) definitions match exactly? Informal sources can mislead about the precise result. Read primary sources at the design stage.

**Formalization adds lemmas for implicit hypotheses.** When an informal proof says "X follows because the construction has property P," the formal proof needs an explicit predicate for P and a lemma proving the construction satisfies it. Having more intermediate lemmas than the paper is EXPECTED — the extra lemmas make implicit paper assumptions explicit. Don't conflate "fewer lemmas" with "closer to the paper"; the paper's argument structure matters more than its lemma count.

Before attempting a `sorry`, estimate the probability of proving it directly (e.g., 30%, 50%, 80%) and report this. If the probability is below ~50%, first factor the `sorry` into intermediate lemmas — smaller steps that are each individually likely to succeed. This avoids wasting long build-test cycles on proofs that need restructuring.

**Recognize thrashing and ask the user.** After 3+ failed approaches to the same goal, stop and ask for guidance. Signs: repeated restructuring, oscillating between approaches, growing helper count without progress. A 2-minute conversation is cheaper than 30 minutes of failed builds.

**Never silently abandon an agreed plan.** If a plan was approved and a step turns out harder than expected, do NOT silently switch to a shortcut (e.g., replacing a proof with `native_decide` or `sorry`). Always confirm radical plan changes with the user first — explain what's hard, what the alternatives are, and let them decide. A 2-minute conversation about changing course is far cheaper than discovering the change broke assumptions downstream.

**Assess proof risk before significant work.** Break non-trivial theorems into phases with risk levels: LOW (definition, direct proof), MEDIUM (standard argument, uncertain details), HIGH (novel connection, unclear if approach works). Identify the highest-risk phase, document fallback plans (axiomatize, defer, reformulate), and validate the critical bottleneck lemma before building dependencies. Escalate to user after 2-3 failed attempts on a MEDIUM+ phase.

**Analyze uncertain lemmas in natural language before formal proof attempts.** Work through the math with concrete examples BEFORE formalizing: (1) test the proof idea with specific numbers, (2) look for counterexamples, (3) verify each step informally, (4) only then formalize. Informal analysis is instant vs. 20s-2min build cycles. A careful analysis can reveal a lemma is unprovable (saving days) or clarify the exact proof structure needed.

**Keep proofs small and factored.** If a proof has more than ~3 intermediate `have` steps, factor them into standalone lemmas. Each lemma should have a small, independently testable interface — this avoids churning where fixing one step breaks steps below it.

**When a user suggests an approach or lesson, rephrase it for AGENTS.md** rather than copying verbatim. Lessons should be concise, actionable, and fit the existing style.

**Work autonomously on low-risk tasks once the path is clear.** When reduced to well-understood engineering (Mathlib interfacing, type bridging, assembling existing components), continue autonomously. Check in when hitting unexpected obstacles, discovering the approach won't work, or completing major milestones. Progress over permission when risk is low.

**Review subtle definitions interactively before building downstream infrastructure.** Definitions that involve distinguishability (e.g., 0-1 values vs labeled elements) or quantifier structure (∀ permutations vs ∀ Boolean sequences) can be subtly wrong in ways that only surface when attempting proofs. When a definition is the foundation for multiple sorry'd lemmas, validate it with the user before committing to downstream work.

**"Easy to see" in papers is a red flag for formalization.** When a paper says "it is easy to see" without proof, validate the *proof strategy* — not just the statement — before investing in Lean infrastructure. Always ask: "what is the proof, not just the claim?"

**Sanity-check formulas empirically.** Before a long proof, write a Python script with `numpy`/`scipy.integrate.quad` that evaluates the formula at specific parameter values and compares to numerical integration. A mismatch at this stage is much cheaper to find than mid-proof.

## Aristotle / Claude Code Workflow

This repo uses the autonomous autoformalization lifecycle adapted from the
Clawristotle template (no Telegram `alert` step):
- Codex/human reviewer owns mathematical direction, critiques statements, and
  accepts or rejects architecture changes.
- Claude Code acts as implementation engineer and uses `.claude/commands/`. One
  `babysit` cycle runs, in order: `critique` → `plan` → `submit-aristotle` →
  `prove` → `check-aristotle` → `simplify` → `strengthen` → `log` → `cleanup` →
  `commit`. Every step must run; every cycle must make progress.
  `aristotle-structure-critique` is a standalone pre-implementation command, not
  part of the cycle.
- Adversarial critique runs in two places: the Claude `/critique` babysit step
  (self-review into `CRITICISMS.md`) and Codex's independent
  `.codex/commands/critique.md`. Codex still owns the authoritative review; the
  Claude step front-loads obvious issues each cycle and does not replace it.
- The `commit` step commits and pushes (to a topic branch, never force-pushing or
  pushing directly to the default branch). Alerts, external chat-model
  consultation, CI/deploy checks, and visualization/report generation remain
  intentionally omitted.
- Aristotle state lives under `aristotle/`: `aristotle-jobs.json`,
  `aristotle-in/`, `aristotle-out/`, `check-aristotle.py`, and
  `STRUCTURE_CRITIQUE.md`.
- Live Aristotle submission uses the project-local `.venv`:
  `.venv/bin/aristotle` / `.venv/bin/python aristotle/check-aristotle.py`.
  `aristotlelib` is installed there; API credentials are still required via
  `ARISTOTLE_API_KEY` or local `.env`. If credentials are unavailable, prepare
  standalone input files and record the blocker rather than pretending a job was
  submitted.
- First Aristotle-facing use is structure stress-testing: once `Basic.lean` has
  real definitions, extract standalone Lean obligations for `endToEnd_N2`,
  `balanced_N2`, `regularizerSq_N2`, and small definition-sanity checks.

## Proof tactics
*(Build out as we go.)* After completing each proof, reflect: if there's a
reusable lesson — a tactic pattern, a Mathlib gotcha, a refactor that unlocked
progress — add it here (not in auto memory). When the user suggests an approach,
**rephrase it concisely** for this file rather than copying verbatim.

- **Typed wrapper to kill `Fin.cons`/`Fin.snoc` dependent-motive errors.** Writing
  `Fin.cons (1 : GL ..) (gaugeL A) i.castSucc` elaborates the *dependent* `Fin.cons`
  with an uninferable motive ("has type `?m i.castSucc`"). Fix: wrap in a `def` with
  an explicit non-dependent type (`def gaugeV A : Fin (L+2) → GL .. := Fin.cons 1 (gaugeL A)`)
  and prove `@[simp]` evaluation lemmas (`gaugeV_zero/succ/castSucc/last`). Then
  downstream `simp` rewrites cleanly and never sees the raw `Fin.cons`.
- **`simp` prefers `List.ofFn_succ` (split first) over `ofFn_succ'` (split last).**
  When you need the *last*-element split (e.g. `Fin.snoc` tuples, where index 0's
  value is boundary-dependent), force it with `rw [List.ofFn_succ']` before `simp`.
- **Noncommutative telescoping** (`reverseProd_conjChain`): induct with the foralls
  *inside* the statement (`∀ {n} c P, …`) and `intro n; induction n` so the IH is
  `∀ c P` and can be applied to shifted gauges `(c ∘ Fin.succ)`. Close the step with
  `simp only [List.ofFn_succ, …, Fin.castSucc_succ]; rw [ih …]; simp only [mul_assoc,
  Units.inv_mul_cancel_left]`. Unit cancellation in matrix products: `Units.mul_inv`
  / `Units.inv_mul` (`↑u * ↑u⁻¹ = 1`) and `Units.inv_mul_cancel_left`.
- **`def` unfolding:** `rw [myDef]` fails on a plain `def`; use `unfold myDef`,
  `simp only [myDef]`, or `show`. (`rw` only takes equational lemmas.)
- **Matrix-valued `HasDerivAt` instance diamond (the `le:moments` blocker, now solved).**
  `Matrix` carries two non-defeq `TopologicalSpace`s: the default `instTopologicalSpaceMatrix`
  (Pi) and the metric one from `open scoped Norms.Frobenius`. Writing/ascribing ANY
  matrix-valued `HasDerivAt` goal resolves the *default* instance, but
  `hasDerivAt_exp_smul_const` returns a *Frobenius* term → "Type mismatch …
  `instTopologicalSpaceMatrix` vs `frobeniusNormedRing…`". Fix: **never ascribe a
  matrix-valued `HasDerivAt` type.** Build them only as inferred `have`s from the exp lemma
  and `.mul`/`.mul_const`/CLM combinators (Frobenius rides along in the inferred type), then
  land in ℝ via `(CLM.hasFDerivAt).comp_hasDerivAt 0 h`. The ℝ-valued conclusion mentions no
  matrix topology, so it is diamond-free and reusable *outside* the Frobenius section. Keep
  all matrix-valued differentiation inside one `section / open scoped Norms.Frobenius / end`.
- **CLMs from finite-dim linear maps (inside the Frobenius section):**
  `(Matrix.traceLinearMap (Fin d) ℝ ℝ).toContinuousLinearMap`,
  `(Matrix.transposeLinearEquiv (Fin d) (Fin d) ℝ ℝ).toLinearMap.toContinuousLinearMap`;
  their `_apply` lemmas are `rfl`.
- **Uniform gauge-curve coercion kills per-index case analysis:**
  `(gaugeL (gaugeExp t a) k : Matrix) = exp (t • leftGen a k)` and
  `((gaugeR (gaugeExp t a) k)⁻¹ : Matrix) = exp (t • rightGen a k)` where
  `leftGen = Fin.snoc a 0`, `rightGen = Fin.cons 0 (-a)` (wrap these in named `def`s with
  `@[simp]` eval lemmas to dodge the `snoc`/`cons` dependent-motive error). One
  `Fin.lastCases`/`Fin.cases` each; inverse needs `Matrix.coe_units_inv`, `IsUnit.unit_spec`,
  `← Matrix.exp_neg`, `smul_neg`. ⇒ a single reusable summand `HasDerivAt`, no index split.
- **Trace-pairing nondegeneracy:** `Matrix.ext_iff_trace_mul_left : A = B ↔ ∀ x,
  (x*A).trace = (x*B).trace`. From `∀ a, ∑_j 2·Tr(a_j G_j) = 0` derive `G_j = 0`: fix `j₀`,
  take `a = Pi.single j₀ x`, `rw [Fintype.sum_eq_single j₀ …]`, `Pi.single_eq_same`/`_of_ne`,
  `linarith` to drop the `2*`.
- **`HasDerivAt.sum` returns `(∑ i, fun t => f i t)` (pointwise sum of functions), not
  `fun t => ∑ i, f i t`.** Bridge the goal's `fun t => ∑ …` with a
  `funext t; simp only [Finset.sum_apply]` equation before `exact`.
- **First-order minimum:** `IsMinOn g Set.univ 0` (+ `Filter.univ_mem`) ⇒ `IsMinOn.isLocalMin`
  ⇒ `IsLocalMin.hasDerivAt_eq_zero hg hd` forces the `HasDerivAt` value to `0`. Pair with
  `gaugeExp_zero_smul : gaugeExp 0 a • W = W` to evaluate `g 0 = regularizerSq W`.

## Mathlib API reference
*(Build out as we go — record exact signatures; they are not reliably memorable.
Grep the source — `grep -rn "theorem <name>" .lake/packages/mathlib/Mathlib/` —
rather than recalling argument order / `_root_.` prefixes.)*

Confirmed signatures (Mathlib v4.31.0):
- `Real.sqrt_le_sqrt_iff (hy : 0 ≤ y) : √x ≤ √y ↔ x ≤ y` — the squared/unsquared bridge.
- `Matrix.posSemidef_conjTranspose_mul_self (A) : (Aᴴ * A).PosSemidef`;
  `Matrix.PosSemidef.trace_nonneg : A.PosSemidef → 0 ≤ A.trace`;
  `Matrix.conjTranspose_eq_transpose_of_trivial (A) : Aᴴ = Aᵀ` (over ℝ, `TrivialStar`).
- `isMinOn_iff : IsMinOn f s a ↔ ∀ x ∈ s, f a ≤ f x`.
- `Fin.cons_zero/cons_succ`, `Fin.snoc_castSucc/snoc_last`, `Fin.castSucc_succ`
  (`(succ i).castSucc = (castSucc i).succ`), `Fin.succ_last`, `Fin.castSucc_zero`.
- `List.ofFn_succ` (split first), `List.ofFn_succ'` (split last via `.concat`),
  `List.ofFn_const : ofFn (fun _ => c) = replicate n c`, `List.prod_replicate`.
- `Matrix.detMonoidHom : Matrix n n R →* R`, `Matrix.coe_detMonoidHom`;
  `(MonoidHom).map_list_prod f l : f l.prod = (l.map f).prod`;
  `Matrix.isUnit_iff_isUnit_det`, `isUnit_iff_ne_zero` (field).
- `MulAction.orbit_eq_iff : orbit G a = orbit G b ↔ a ∈ orbit G b`;
  `MulAction.mem_orbit_iff : a₂ ∈ orbit γ a₁ ↔ ∃ g, g • a₁ = a₂`.
- For prefix products: `List.take_add_one` (NOT deprecated `take_succ`; + `getElem?_eq_getElem`,
  `Option.toList_some`), `List.getElem_ofFn`, `List.length_ofFn`, `List.mem_ofFn'`
  (`a ∈ ofFn f ↔ a ∈ Set.range f` — use via `rw`, not `.mpr`), `List.take_of_length_le`,
  `List.prod_eq_zero_iff`. Coercion of a `List` product of units:
  `map_list_prod (Units.coeHom M) l` (after `rw [← Units.coeHom_apply]`), then
  `List.map_reverse`/`List.map_ofFn`. Close `W ⟨n,h⟩ = W (Fin.last/castSucc ..)` index
  mismatches with `congrArg W (Fin.ext rfl)`.
- **Matrix exponential / `le:moments` (analytic step).** `exp` is `NormedSpace.exp (x)`
  (field-free, `irreducible_def`); `Matrix.isUnit_exp` gives `IsUnit (exp A)` with NO norm
  instance. The derivative lemmas are ROOT-level (not `NormedSpace.`-prefixed):
  `hasDerivAt_exp_smul_const (x) (t) : HasDerivAt (fun u => exp (u•x)) (exp (t•x) * x) t`
  (so `d/dt|₀ exp(t•a) = a`), `hasFDerivAt_exp_zero`. **Gotcha (instance diamond):** these need
  a `NormedRing`/`NormedAlgebra` on `Matrix` (`attribute [local instance]
  Matrix.frobeniusNormedAddCommGroup/Ring/Algebra`), whose topology is NOT defeq to the default
  `instTopologicalSpaceMatrix` — so a matrix-valued `HasDerivAt` proved under Frobenius will not
  unify with one stated under default instances. Keep all matrix-valued differentiation inside the
  Frobenius context and only export the final ℝ-valued `HasDerivAt` (its codomain is ℝ, no diamond),
  chaining through `trace`/`*` as Frobenius-continuous-linear maps. **SOLVED in `MomentMap.lean`**
  (see Proof-tactics: never ascribe matrix `HasDerivAt` types; `(CLM.hasFDerivAt).comp_hasDerivAt`).
- **`le:moments` confirmed signatures (v4.31.0):** `open scoped Norms.Frobenius` activates
  `Matrix.frobenius{Seminormed,Normed}AddCommGroup/Space/Ring/Algebra` at once. `HasDerivAt.mul`,
  `HasDerivAt.mul_const`; `HasFDerivAt.comp_hasDerivAt (hl) (hf)`; `ContinuousLinearMap.hasFDerivAt`.
  `LinearMap.toContinuousLinearMap` (needs `[FiniteDimensional ℝ _]`), `…coe_toContinuousLinearMap'`.
  `Matrix.traceLinearMap (Fin d) ℝ ℝ`, `Matrix.transposeLinearEquiv (Fin d) (Fin d) ℝ ℝ`.
  `Matrix.exp_neg : exp (-A) = (exp A)⁻¹`, `Matrix.coe_units_inv`, `NormedSpace.exp_zero`.
  `Matrix.trace_mul_cycle`, `trace_mul_comm`, `trace_transpose`, `trace_neg`, `trace_sub`,
  `ext_iff_trace_mul_left`. `Fin.sum_univ_castSucc`/`Fin.sum_univ_succ`, `Finset.sum_apply`,
  `Fintype.sum_eq_single`. `IsMinOn.isLocalMin` (+`Filter.univ_mem`), `IsLocalMin.hasDerivAt_eq_zero`,
  `HasDerivAt.unique`.

## MCP tooling and `lake` fallback
`.mcp.json` wires up **`lean-lsp-mcp`** (`uvx lean-lsp-mcp`), talking to a
persistent `lake serve` LSP. **Use the MCP tools as the default check-loop — read
the goal state and diagnostics after every edit rather than guessing — and
reserve `lake build` for full verification.** A warm LSP query is sub-second; a
full `lake build` re-elaborates against all of Mathlib, so it is the fallback,
not the inner loop. Run `lake build` once at session start to warm imports.

Core loop (LSP-backed, fast, no network):
- `lean_diagnostic_messages` — all errors/warnings for a file; the primary "did
  my edit compile?" check.
- `lean_goal` — tactic state at a line/column; the workhorse for stepping a proof.
- `lean_term_goal` — expected type at a term hole.
- `lean_hover_info` — docs + signature for a symbol.
- `lean_completions` — identifiers/imports valid at a position.
- `lean_declaration_file` / `lean_references` — read a lemma's source / find uses.
- `lean_multi_attempt` — try several tactics at one position, compare resulting
  goals, pick the winner without a rebuild.
- `lean_run_code` — run an independent snippet (`#check` / `#eval`).
- `lean_verify` — list the axioms a finished proof uses; scan for unsafe code.

Lemma search (local first; the rest are external, rate-limited ~3 req / 30 s):
- `lean_local_search` — ripgrep over the local project + stdlib (needs `rg`).
- `lean_loogle` — Mathlib search by name / subexpression / type signature.
- `lean_leansearch` — natural-language search over Mathlib.
- `lean_state_search` / `lean_hammer_premise` — theorems / premises for the goal.

Fallback / recovery:
- `lean_build` (MCP) or `lake build` (shell) — full build + restart the LSP; use
  when LSP state goes stale.

Plain shell build (CI and first checkout):
    lake exe cache get      # once: download prebuilt Mathlib oleans
    lake build              # full verification
    bash scripts/no_sorry.sh
