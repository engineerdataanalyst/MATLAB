%% given
u = symunit;
Wdot = 0.4*u.kW;
V1 = 0;
D2 = 0.6*u.m;
V2 = 12*u.m/u.s;
rho = 1.23*u.kg/u.m^3;

%% first law of thermodynamics
syms loss;
A2 = sympi*D2^2/4;
mdot = rho*A2*V2;
wshaft = rewrite(Wdot/mdot, [u.kJ u.kg]);
eqn = rewrite(V2^2/2 == V1^2/2+wshaft-loss, [u.kJ u.kg]);
loss = rewrite(simplify(solve(eqn)), [u.kJ u.kg]);

%% fan efficiency
n = double((wshaft-loss)/wshaft);