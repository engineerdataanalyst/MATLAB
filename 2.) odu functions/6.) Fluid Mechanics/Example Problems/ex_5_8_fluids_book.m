%% given
u = symunit;
Q2 = 300*u.cm^3/u.min;
Q1 = 0.10*Q2; %(Qloeak)
A1 = 500*u.mm^2; %(Ap)

%% conservation of mass
syms Vp;
eqn = rewrite(A1*-Vp+Q1+Q2 == 0, [u.mm u.min]);
Vp = solve(eqn);