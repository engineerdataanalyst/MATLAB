syms a0 a1 a2 a3;
syms wi thetai wj thetaj;
syms x L E I p;

u(x) = a0+a1*x+a2*x^2+a3*x^3;
du = diff(u);

[a eqn] = deal(sym.zeros(4,1));
eqn(1) = u(0) == wi;
eqn(2) = du(0) == thetai;
eqn(3) = u(L) == wj;
eqn(4) = du(L) == thetaj;
[a(1) a(2) a(3) a(4)] = solve(eqn, a0, a1, a2, a3);

u = subs(u, [a0 a1 a2 a3], a.');
du = subs(du, [a0 a1 a2 a3], a.');
u = collect(u, [wi thetai wj thetaj]);
du = collect(du, [wi thetai wj thetaj]);

N = coeffs(u, [thetaj wj thetai wi]).';
B = coeffs(du, [thetaj wj thetai wi]).';
K = E*I*int(diff(B)*diff(B).', 0, L);
peq = int(p*N, 0, L);