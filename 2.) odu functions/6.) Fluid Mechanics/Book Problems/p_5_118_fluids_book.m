%% given
u = symunit;
Q = 80*u.gal/u.min;
[pout1 pout2] = deal(0);
[Vout1 Vout2] = deal(0);
[zout1 zout2] = deal(0, 50*u.ft);
[pin1 pin2] = deal(0);
[Vin1 Vin2] = deal(0);
[zin1 zin2] = deal(50*u.ft, 0);
rho = 1.94*u.slug/u.ft^3;
g = 32.2*u.ft/u.s^2;

%% first law of thermodynamics (flow going downstream)
syms loss;
wshaft1 = 0;
eqn1 = pout1/rho+Vout1^2/2+g*zout1 == pin1/rho+Vin1^2/2+g*zin1+wshaft1-loss;
eqn1 = rewrite(eqn1, [u.ft u.lbf u.slug]);
loss = solve(eqn1);

%% first law of thermodynamics (flow going downstream)
syms wshaft2;
mdot = rho*Q;
eqn2 = pout2/rho+Vout2^2/2+g*zout2 == pin2/rho+Vin2^2/2+g*zin2+wshaft2-loss;
eqn2 = rewrite(eqn2, [u.ft u.lbf u.slug]);
wshaft2 = solve(eqn2);
Wshaft2 = rewrite(mdot*wshaft2, u.HP_UK);