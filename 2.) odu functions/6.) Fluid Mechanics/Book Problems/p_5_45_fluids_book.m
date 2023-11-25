%% given
u = symunit;
D1 = 300*u.mm;
p1 = 100*u.kPa;
V1 = 2*u.m/u.s;
D2 = 160*u.mm;
p2 = 0;
rho = 1000*u.kg/u.m^3;

%% conservation of mass
syms V2;
A1 = sympi*D1^2/4;
A2 = sympi*D2^2/4;
V2 = solve(rewrite(A1*V1 == A2*V2, u.m));

%% conservation of momentum
syms Rx;
eqn = rewrite(Rx+p1*A1+p2*A2 == rho*(V1*V1*A1*-1-V2*V2*A2), u.kN);
Rx = solve(eqn);