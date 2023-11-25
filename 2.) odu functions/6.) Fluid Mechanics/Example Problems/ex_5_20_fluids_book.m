%% given
u = symunit;
Q = 300*u.gal/u.min;
D1 = 3.5*u.in;
D2 = 1*u.in;
p1 = 18*u.psi;
p2 = 60*u.psi;
u2_u1 = 93*u.ft*u.lbf/u.lbm;
rho = 1.94*u.slug/u.ft^3;

%% conservation of mass
mdot = rewrite(rho*Q, u.lbm/u.s);
A1 = sympi/4*D1^2;
A2 = sympi/4*D2^2;
V1 = rewrite(Q/A1, u.ft/u.s);
V2 = rewrite(Q/A2, u.ft/u.s);

%% first law of thermodynamics
Wdot = mdot*(u2_u1+(p2-p1)/rho+(V2^2-V1^2)/2);
Wdot = rewrite(simplify(Wdot), u.HP_UK);