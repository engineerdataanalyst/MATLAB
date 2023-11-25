%% given
u = symunit;
D1 = 4*u.in;
p1 = 100*u.psi;
T1 = 540*u.Rankine;
V2 = 1000*u.ft/u.s;
D2 = 4*u.in;
p2 = 18.4*u.psi;
T2 = 453*u.Rankine;
R = 53.34*u.ft*u.lbf/(u.lbm*u.Rankine);

%% conservation of mass
syms V1;
rho1 = p1/(R*T1);
rho2 = p2/(R*T2);
A1 = sympi*D1^2/4;
A2 = sympi*D2^2/4;
V1 = solve(rewrite(rho1*A1*V1 == rho2*A2*V2, [u.ft u.s]));

%% conservation of momentum
syms Rx;
eqn = rewrite(-Rx+(p1-p2)*A1 == rho1*V1*V1*A1*-1+rho2*V2*V2*A2, u.lbf);
Rx = solve(eqn);