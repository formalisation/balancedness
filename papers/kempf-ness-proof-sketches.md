# The length of vectors in representation spaces — main theorems and proof sketches

A reader's guide to

> George Kempf and Linda Ness, *"The length of vectors in representation spaces"*,
> in *Algebraic Geometry (Copenhagen 1978)*, Lecture Notes in Mathematics **732**,
> Springer-Verlag, pp. 233–243.

This is the original source of the **Kempf–Ness theorem**. The notes below state the
four main results and sketch their proofs, following the paper's own architecture
(§1 abstract convexity → §2 tori → §3 reductive groups → §4 stability), and close
with the moment-map interpretation.

---

## 0. Setup

Let $G$ be a connected reductive group over $\mathbb{C}$ acting (morphically) on a
finite-dimensional complex vector space $V$. Fix a maximal compact subgroup
$K \subset G$ and a **$K$-invariant Hermitian norm** $\lVert\cdot\rVert$ on $V$.

For a fixed vector $v \in V$, define the **length function**

$$p_v(g) \;=\; \lVert g\cdot v\rVert^2, \qquad g \in G.$$

Two invariances are immediate:

- **Left $K$-invariance:** $p_v(kg) = \lVert kg\cdot v\rVert^2 = \lVert g\cdot v\rVert^2$, since $K$ preserves the norm.
- **Right $G_v$-invariance:** for $h \in G_v$, $p_v(gh) = \lVert gh\cdot v\rVert^2 = \lVert g\cdot v\rVert^2$, since $h\cdot v = v$.

So $p_v$ is constant on the double cosets $K\cdot g\cdot G_v$ and descends to the
symmetric space $K\backslash G$ (and further to $K\backslash G / G_v$). We write
$p_v'$ for the induced function on $K\backslash G$.

---

## 1. The main theorems

**Theorem 0.1 (rigidity of $p_v$).**
1. *(a)* Every **critical point** of $p_v$ is a point where $p_v$ attains its **global minimum**.

   If $p_v$ attains a minimum value, then:
2. *(b)* the minimum set $m$ is a **single double coset** $K\cdot G_v$, and it is **connected**;
3. *(c)* the second-order variation of $p_v$ at a point of $m$ is **strictly positive in every direction not tangent to $m$**.

**Theorem 0.2 (Kempf–Ness).**
The vector $v$ is **stable** (i.e. the orbit $G\cdot v$ is closed and $v\neq 0$)
**if and only if** $p_v$ attains a minimum value.

**Theorem 4.1.**
If $v$ is **properly stable** (stable and $G_v$ **finite**), then
1. *(a)* the induced function $p_v'$ on $K\backslash G$ is a **Morse function with exactly one critical point**, where it attains its minimum;
2. *(b)* if moreover the minimum is at the identity $e$, then $G_v \subseteq K$.

   Conversely, if $p_v'$ attains a minimum at a unique point of $K\backslash G$, then $v$ is properly stable.

**Corollary 4.2.**
If $v$ is properly stable, $G_v \subseteq K$, and $K = \{\, g\in G : gG_vg^{-1}\subseteq K \,\}$,
then $p_v$ attains its minimum at $e$. (Satisfied e.g. when $G=\mathrm{SL}(W)$ and $G_v$ acts irreducibly on $W$.)

---

## 2. The single idea behind everything

Transport $p_v$ to the symmetric space $X = K\backslash G$. This space carries
nonpositive curvature and is a **union of flats**

$$X \;=\; \bigcup_{T\in\mathcal{T}} K_T\backslash T,$$

one totally-geodesic flat $K_T\backslash T \cong \mathbb{R}^{\dim T}$ for each maximal
torus $T$ (Cartan decomposition; $\mathcal{T}$ is the family of maximal tori $T$ with
$K\cap T$ a maximal compact of $T$). On each flat, in the logarithmic coordinates
$x_i = \log|t_i|$, the function $p_v$ becomes a **finite sum of exponentials of linear
functions**:

$$p_v'(x) \;=\; \sum_i a_i\, e^{\ell_i(x)}, \qquad a_i>0,\ \ell_i \text{ affine}.$$

Such functions are **convex**, and the whole theory reduces to elementary facts about
them:

> *critical $\Rightarrow$ minimum; the minimum locus is an affine subspace;
> strictly convex transverse to that locus.*

Stability becomes a **coercivity** question: does this convex function attain its
infimum, or does some direction escape to a finite infimum it never reaches? That
escaping direction is precisely a Hilbert–Mumford destabilizing one-parameter subgroup.

---

## 3. §1 — Special functions on affine spaces

**Definition.** A *special function* on a finite-dimensional real affine space $A$ is a
finite sum $f = \sum_i e^{H_i}$ with each $H_i$ an affine function on $A$. It is
*degenerate* if its restriction to every line is constant; *nondegenerate* otherwise.

(Each $e^{H_i}$ is the exponential of an affine function, hence convex; a sum of convex
functions is convex. So **every** special function is convex — strictness is the only
issue.)

### Lemma 1.1 (one variable)
Write a special function on $\mathbb{R}$ uniquely as $f(x)=\sum_i a_i e^{\ell_i x}$ with
$a_i>0$ and the $\ell_i$ distinct. Then $f''\ge 0$; if $f''=0$ anywhere then $f$ is
constant; and a nonconstant such $f$ is a strictly convex Morse function.

*Proof sketch.* Differentiate twice:
$$f''(x) = \sum_i a_i\,\ell_i^{2}\, e^{\ell_i x},$$
a sum of nonnegative terms, so $f''\ge 0$. If $f''(x_0)=0$ for some $x_0$ then each
summand vanishes, i.e. $a_i\ell_i^2=0$; since $a_i>0$ this forces $\ell_i=0$ for all
$i$, so $f$ is constant. Hence a nonconstant $f$ has $f''>0$ everywhere — strictly
convex, with a nondegenerate critical point if any. $\qquad\blacksquare$

### Proposition 1.2 (nondegenerate case)
A nondegenerate special function $f$ on an affine space is strictly convex and Morse;
consequently, **if it has a critical point, that point is its unique minimum**.

*Proof sketch.* Restrict $f$ to an arbitrary line $L$. The restriction is again a
special function on $L\cong\mathbb{R}$, and nondegeneracy means it is nonconstant, so by
Lemma 1.1 it is strictly convex. A function strictly convex on every line is strictly
convex, hence has positive-definite Hessian; a critical point of a strictly convex
function is the unique global minimum. $\qquad\blacksquare$

### Lemma 1.3 (reduction to the nondegenerate case)
For any special function $f$ on $A$ there is a **unique** affine quotient
$\pi\colon A \to B$ and a **nondegenerate** special function $g$ on $B$ with
$f = g\circ\pi$.

*Proof sketch.* Through each point $a$ there is a maximal affine subspace $M_a$ on which
every $H_i$ is constant (the common "flat directions" of the exponents). These $M_a$ are
parallel translates of a fixed subspace, so they are the fibers of an affine quotient
$\pi\colon A\to B := A/\{M_a\}$. Since each $H_i$ is constant along fibers, $f$ descends
to $g$ on $B$; maximality of the $M_a$ makes $g$ nondegenerate. Uniqueness is clear. $\qquad\blacksquare$

### Theorem 1.4 (general special function)
A special function $f$ on $A$ satisfies:
(a) $f$ is convex;
(b) $f$ has no critical points outside its minimum set $m$;
(c) $m$ is an affine subspace of $A$;
(d) the second-order variation at any point of $m$ is positive in every direction not
tangent to $m$.

*Proof sketch.* Factor $f = g\circ\pi$ (Lemma 1.3) with $g$ nondegenerate. By
Proposition 1.2, $g$ is strictly convex Morse on $B$, so it has a unique minimum point
$b_0$ (if any), with positive-definite Hessian there. Pulling back by the affine
submersion $\pi$: $f$ is convex; its critical/minimum set is the affine fiber
$m=\pi^{-1}(b_0)$; and the Hessian of $f$ is positive in exactly the directions
transverse to the fibers, i.e. transverse to $m$. $\qquad\blacksquare$

**This is Theorem 0.1, stated in pure linear-algebra terms.** The rest of the paper is
the work of showing that $p_v$, read on the symmetric space, *is* such a function.

---

## 4. §2 — The toroidal case ($G = T = (\mathbb{C}^\times)^n$)

Here $K_T = (S^1)^n$ consists of the unit-modulus tuples. Decompose $V$ into **weight
spaces**

$$V = \bigoplus_{\chi} V_\chi, \qquad \chi(t)=\textstyle\prod_i t_i^{m_i},\ (m_i)\in\mathbb{Z}^n.$$

$K_T$-invariance of the norm forces distinct weight spaces to be **orthogonal**.

### Lemma 2.1
Let $\Xi(v)\subset\mathbb{Z}^n$ be the set of weights occurring in $v=\sum_\chi v_\chi$.
Then
$$p_v(t) = \sum_{(m_i)\in\Xi(v)} \lVert v_{(m_i)}\rVert^2 \prod_i |t_i|^{2m_i},$$
and the stabilizer is $T_v=\{t : \prod_i t_i^{m_i}=1\ \text{for all } (m_i)\in\Xi(v)\}$.

*Proof sketch.* Since $t\cdot v=\sum_{(m_i)} \chi(t)\,v_{(m_i)}$ and the $V_\chi$ are
orthogonal, the cross terms vanish and
$\lVert t\cdot v\rVert^2 = \sum_{(m_i)} |\chi(t)|^2\,\lVert v_{(m_i)}\rVert^2$, with
$|\chi(t)|^2 = \prod_i|t_i|^{2m_i}$. The stabilizer description is read off from
$t\cdot v=v$ on each (nonzero) weight component. $\qquad\blacksquare$

### Lemma 2.2 (coordinates $x_i=\log|t_i|$)
On $K_T\backslash T \cong \mathbb{R}^n$,
$$p_v'(x) = \sum_{(m_i)\in\Xi(v)} e^{\,c_{(m_i)} + 2\sum_i m_i x_i}, \qquad c_{(m_i)}=\log\lVert v_{(m_i)}\rVert^2,$$
and the degeneracy locus $\{x : \sum_i m_i x_i = 0\ \forall (m_i)\in\Xi(v)\}$ is the image
of $T_v$.

*Proof sketch.* Substitute $|t_i|^{2m_i} = e^{2m_i x_i}$ into Lemma 2.1; the positive
coefficient becomes $e^{c_{(m_i)}}$. This is literally a special function whose exponents
are the linear forms $x\mapsto 2\langle m,x\rangle$. $\qquad\blacksquare$

**Conclusion (Theorem 0.1 for tori).** Apply Theorem 1.4 to the special function
$p_v'$. The minimum set $m$ corresponds (via Lemma 1.3's quotient) to
$K_T\backslash T / T_v$ — i.e. a single $K_T$–$T_v$ coset — and $p_v'$ is strictly
convex transverse to it. This is parts (a)–(c) for a torus. $\qquad\blacksquare$

---

## 5. §3 — The reductive case, via Cartan

Embed $G$ over $\mathbb{R}$ with $K$ as the real locus; let $\mathcal{T}$ be the family of
maximal tori $T$ with $K\cap T = K_T$ maximal compact in $T$. The **Cartan decomposition**
gives both
$$\text{(1)}\quad K\backslash G = \bigcup_{T\in\mathcal{T}} K_T\backslash T,
\qquad
\text{(2)}\quad T_K(K\backslash G) = \bigcup_{T\in\mathcal{T}} T_{K_T}(K_T\backslash T),$$
the second being the infinitesimal (tangent-space) form. Every point/geodesic-direction
of $X=K\backslash G$ lies in **some flat** $K_T\backslash T$, and that is all we need.

### Part (a): critical $\Rightarrow$ minimum
Translating by $h$ (using $p_{h\cdot v}(g)=p_v(gh)$), assume $e$ is the critical point.
Take any $g\in G$ and write $g = k\cdot t$ with $k\in K$, $t\in T$, $T\in\mathcal{T}$
(Cartan). Left $K$-invariance gives $p_v(g)=p_v(t)$. Now $e$ is a critical point of the
restriction $p_v|_T$, so the **toroidal case** says $e$ is the minimum of $p_v|_T$, i.e.
$p_v(t)\ge p_v(e)$. Hence $p_v(g)\ge p_v(e)$ for all $g$: $e$ is a global minimum. $\qquad\blacksquare$

### Part (b): the minimum set is one connected coset
Translate so the minimum is at $e$; then $K\cdot G_v \subseteq m$ automatically (by the two
invariances). Conversely take $g\in m$ and write $g=kt$. Then $t$ minimizes $p_v|_T$, so by
the toroidal case $t \in K_T\cdot T_v$, a **connected** set containing $e$. Therefore
$$m \;\subseteq\; K\cdot\!\!\bigcup_{T\in\mathcal{T}}\!\! K_T\cdot T_v \;\subseteq\; K\cdot G_v,$$
and combined with $K\cdot G_v\subseteq m$ this gives $m = K\cdot G_v$. It is connected
because $K$ is connected (as $G$ is) and each $K_T\cdot T_v$ is connected. $\qquad\blacksquare$

### Part (c): transverse positivity
Reduce to directions through $e$. Let $X$ be a tangent vector at $K\in K\backslash G$ with
**zero** second variation of $p_v'$ along $X$. By the tangent-space decomposition (2), $X$
is tangent to some flat $K_T\backslash T$. By the toroidal case (Theorem 1.4(d)), a
direction of vanishing second variation must be tangent to
$K_T\backslash K_T\cdot T_v \subseteq K\backslash K\cdot G_v$ — i.e. tangent to $m$. So the
normal Hessian has no kernel: it is positive definite transverse to $m$. $\qquad\blacksquare$

---

## 6. §4 — Analysis of stability (Theorem 0.2)

Recall the stability notions for $v\neq 0$:
- **unstable:** $0\in\overline{G\cdot v}$;
- **not stable:** $G\cdot v$ is not closed;
- **stable:** $G\cdot v$ is closed (and $v\neq 0$);
- **properly stable:** stable and $G_v$ **finite**.

A trivial criterion: $\;(\dagger)\;\; v \text{ unstable} \iff \inf p_v = 0$ (the orbit
closure reaches $0$).

To prove Theorem 0.2 it suffices to show
$$(\ast)\qquad v \text{ not stable} \;\Longrightarrow\; \inf p_v \text{ is not attained.}$$

### Easy direction: stable $\Rightarrow$ minimum attained
If $G\cdot v$ is closed and $v\neq0$, the function $w\mapsto\lVert w\rVert^2$ is **proper**
on the closed set $G\cdot v$ (sublevel sets are closed and bounded, hence compact), so it
attains a minimum there; equivalently $p_v$ attains a minimum on $G$.

### Hard direction $(\ast)$: reduce to $\mathbb{C}^\times$, then to one exponential sum
1. **Destabilize (Hilbert–Mumford).** If $v$ is not stable, there is a one-parameter
   subgroup $\lambda\colon\mathbb{C}^\times\to G$ with $\lim_{t\to0}\lambda(t)\cdot v$
   existing in $V$ but lying **outside** the orbit $G\cdot v$ (refs [1] Birkes, [6] Kempf).
   The destabilizing $\lambda$ can be chosen inside a parabolic $P$; intersecting $P$ with
   its conjugate $\overline{P}$ under the real structure yields a maximal torus
   $S\in\mathcal{T}$ defined over $\mathbb{R}$ containing such a $\lambda$.
2. **Reduce to a rank-one torus.** The induced $\mathbb{C}^\times$-action via $\lambda_S$
   still has $v$ non-stable, and its maximal compact preserves the norm. Since $(\ast)$ for
   $\mathbb{C}^\times$ implies $(\ast)$ for $G$, assume $G=\mathbb{C}^\times$ with
   $\lim_{t\to0} t\!*\!v$ existing and $\neq v$.
3. **One-variable special function.** On
   $K_{\mathbb{C}^\times}\backslash\mathbb{C}^\times \cong \mathbb{R}$, write
   $p_v'(x) = \sum_i a_i e^{\ell_i x}$ with $a_i>0$ and increasing $\ell_i$. Here
   $x=\log|t|$, so $t\to0$ corresponds to $x\to-\infty$.
   - The limit as $x\to-\infty$ **exists** $\Rightarrow$ no exponent is negative, i.e. all $\ell_i\ge 0$.
   - The limit **$\neq v$** $\Rightarrow$ the function is nonconstant, so some $\ell_i>0$.

   Hence $p_v'(x)=\sum a_i e^{\ell_i x}$ is **strictly increasing**: its infimum is the
   limit value at $x\to-\infty$, which is **never attained**. This is exactly $(\ast)$. $\qquad\blacksquare$

Combining $(\ast)$ with the easy direction proves **Theorem 0.2**.

### Theorem 4.1 and Corollary 4.2
If $v$ is properly stable then by Theorems 0.1 and 0.2 the critical set of $p_v$ equals its
(attained) minimum set $m = K\cdot G_v$. Since $G_v$ is **finite**, this double coset is a
single $K$-coset, i.e. **one point** of $K\backslash G$. Theorem 0.1(c) makes the Hessian
there positive definite — so $p_v'$ is a Morse function with a unique critical point
(part a). If the minimum is at $e$, then $K\cdot G_v=K$ forces $G_v\subseteq K$ (part b);
the converse runs backward through the same chain (a unique minimum forces $G_v$ to be a
compact algebraic — hence finite — subgroup of $G$, so $v$ is properly stable).

Corollary 4.2: the stabilizer of $g\cdot v$ is $gG_vg^{-1}$, and Theorem 4.1 says a
minimum at $g$ requires $gG_vg^{-1}\subseteq K$. The hypothesis
$K=\{g : gG_vg^{-1}\subseteq K\}$ then pins the minimum coset to $K$ itself, i.e. to $e$.

---

## 7. Modern interpretation: the moment map

$p_v=\lVert\cdot\rVert^2$ is the **Kempf–Ness function**. Its critical points are exactly
the zeros of the **moment map** $\mu$ for the $K$-action on $\mathbb{P}(V)$ (or on $V$):
$$\langle \mu(w), \xi\rangle \;\propto\; \tfrac{d}{ds}\Big|_{0}\,\lVert e^{s\xi}\cdot w\rVert^2,\quad \xi\in\mathfrak{k}.$$

Read this way, the results say:

- **Theorem 0.1(a) + Theorem 0.2 = the Kempf–Ness theorem:** a polystable/stable orbit
  contains a vector of minimal length, unique up to $K$ — a zero of the moment map — and
  these "minimal vectors" identify the affine GIT quotient with the symplectic reduction,
  $\;V/\!\!/G \;\cong\; \mu^{-1}(0)/K.$
- **§1–§2 convexity** is the statement that $\log\lVert\cdot\rVert$ is **convex along the
  geodesics** of the nonpositively-curved symmetric space $K\backslash G$, the maximal
  flats being the tori $K_T\backslash T$. This convexity is the analytic counterpart of the
  **Hilbert–Mumford numerical criterion**: instability is detected by a single geodesic
  ray (a one-parameter subgroup) along which the length decreases to an unattained infimum.

---

### References (from the paper)
- [1] D. Birkes, *Orbits of linear algebraic groups*, Ann. of Math. **93** (1971), 459–475.
- [2] A. Borel, *Linear Algebraic Groups*, Benjamin, 1969.
- [6] G. Kempf, *Instability in invariant theory*, Ann. of Math. **108** (1978), 299–316.
- [8] D. Mumford, *Geometric Invariant Theory*, Ergebnisse der Math. (34), Springer, 1965.
