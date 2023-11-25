%% given
% (problem: p. 194)
u = symunit;
Q = 4.25*u.m^3/u.s;
p1 = 415*u.kPa;
z1 = 3*u.m;
D1 = 80*u.mm;
p2 = -double(separateUnits(vpa(rewrite(250*u.mmHg, u.kPa))))*u.kPa;
z2 = 0;
D2 = 80*u.mm;
Wdotshaft = -1100*u.kW;
rho = 999*u.kg/u.m^3;
g = 9.81*u.m/u.s^2;

%% conservation of mass
mdot = rho*Q;
A1 = sympi*D1^2/4;
A2 = sympi*D2^2/4;
V1 = Q/A1;
V2 = Q/A2;

%% mass flow rate into control volume
syms loss;
wshaft = rewrite(Wdotshaft/mdot, u.kJ/u.kg);
eqn = simplify(p2/rho+V2^2/2+g*z2 == p1/rho+V1^2/2+g*z1+wshaft-loss);
loss = rhs(eqn);
Wdotloss = rewrite(mdot*loss, u.kW);