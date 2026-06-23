#!/usr/bin/env python3
"""Numerical sanity check — template.

Empirically verify a closed form / identity BEFORE proving it in Lean. A mismatch
here is far cheaper to find than mid-proof. Pure standard library (math, random)
so it runs anywhere with no dependencies; reach for numpy/scipy only if you need
quadrature or linear algebra.

Replace the body with your project's formula. The pattern: sample many random
parameters in the paper's regime, evaluate both sides of the claim, and assert the
max residual is tiny. (Derivatives via central finite difference; integrals via
scipy.integrate.quad if you add the dependency.)
"""
import math
import random


def lhs(x: float) -> float:
    # <FILL IN: the closed form you intend to prove>
    return math.sin(x) ** 2 + math.cos(x) ** 2


def rhs(x: float) -> float:
    # <FILL IN: what it should equal>
    return 1.0


def main() -> None:
    rng = random.Random(0)
    max_err = 0.0
    for _ in range(2000):
        x = rng.uniform(-10.0, 10.0)        # <FILL IN: sample the paper's regime>
        max_err = max(max_err, abs(lhs(x) - rhs(x)))

    print(f"max residual = {max_err:.3e}")
    assert max_err < 1e-9, "identity does not hold numerically — check the formula"
    print("OK: identity holds numerically.")


if __name__ == "__main__":
    main()
