%% given
u = symunit;
gamma = 9.80*u.kN/u.m^3;
hc = 10*u.m;
D = 4*u.m;

%% section properties
xc = 0;
yc = hc/sin(60*u.deg);
Ixc = sympi*(D/2)^4/4;
Ixyc = 0;
A = sympi/4*D^2;

%% resultant force exerted on the gate
Fr = rewrite(gamma*hc*A, u.MN);
xr = double(Ixyc/(yc*A)+xc);
yr = Ixc/(yc*A)+yc;

%% moment to open gate
syms M;
eqn = rewrite(-M+Fr*(yr-yc) == 0, u.kN);
M = solve(eqn);