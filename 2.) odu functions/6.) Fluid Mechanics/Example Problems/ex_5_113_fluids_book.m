%% given
% (problem: p. 194)
u = symunit;
p1 = 60*u.psi;
Q = 150*u.ft^3/u.s;
D1 = 3*u.ft;
z1 = 10*u.ft;
p2 = -double(separateUnits(vpa(rewrite(10*u.inHg, u.psi))))*u.psi;
D2 = 4*u.ft;
z2 = 0;
Wdotshaft = -2500*u.HP_UK;
rho = 1.94*u.slug/u.ft^3;
g = 32.2*u.ft/u.s^2;

%% conservation of mass
mdot = rho*Q;
A1 = sympi*D1^2/4;
A2 = sympi*D2^2/4;
V1 = Q/A1;
V2 = Q/A2;

%% mass flow rate into control volume
syms loss;
wshaft = rewrite(Wdotshaft/mdot, [u.ft u.lbf u.slug]);
eqn = simplify(p2/rho+V2^2/2+g*z2 == p1/rho+V1^2/2+g*z1+wshaft-loss);
loss = rewrite(rhs(eqn), [u.ft u.lbf u.slug]);
Wdotloss = rewrite(mdot*loss, u.HP_UK);