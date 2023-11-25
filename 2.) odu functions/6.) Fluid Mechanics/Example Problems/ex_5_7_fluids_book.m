%% given
u = symunit;
Q = 1000*u.ml/u.s;
A2 = 30*u.mm^2;
A3 = A2;
rho = 999*u.kg/u.m^3;

%% part A
% conservation of mass
syms Vavg_a;
eqn = rewrite(Q == (A2+A3)*Vavg_a, [u.m u.s]);
Vavg_a = solve(eqn);

%% part B and C
% conservation of mass
Vavg_bc = Vavg_a;