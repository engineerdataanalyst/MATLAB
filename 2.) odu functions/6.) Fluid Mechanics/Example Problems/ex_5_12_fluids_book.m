%% given
u = symunit;
A1 = 0.1*u.ft^2;
A2 = 0.1*u.ft^2;
V1 = 50*u.ft/u.s;
V2 = 50*u.ft/u.s;
p1 = (30-14.7)*u.psi;
p2 = (24-14.7)*u.psi;
rho = 1.940*u.slug/u.ft^3;

%% conservation of momentum in the y-direction
syms Fay clear;
eqn = Fay+(p1+p2)*A1 == rho*(V1*A1*V1*-1-V2*A2*-V2*-1);
eqn = rewrite(eqn, u.lbf);
Fay = solve(eqn);