%% given
u = symunit;
p1 = 100*u.psi;
T1 = 540*u.Rankine;
D1 = 4*u.in;
p2 = 18.4*u.psi;
T2 = 453*u.Rankine;
V2 = 1000*u.ft/u.s;
D2 = D1;

%% conservation of mass
syms R V1;
rho1 = p1/(R*T1);
rho2 = p2/(R*T2);
A1 = pi/4*D1^2;
A2 = pi/4*D2^2;
V1 = solve(rho1*A1*V1 == rho2*A2*V2);