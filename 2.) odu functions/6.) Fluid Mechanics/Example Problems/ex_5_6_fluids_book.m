%% given
u = symunit;
Vcv = 971*u.kmh;
V1 = 0;
A1 = 0.80*u.m^2;
rho1 = 0.736*u.kg/u.m^3;
V2 = -1050*u.kmh;
A2 = 0.558*u.m^2;
rho2 = 0.515*u.kg/u.m^3;

%% conservation of mass
syms mdot_fuel;
W1 = abs(V1-Vcv);
W2 = abs(V2-Vcv);
eqn = rewrite(mdot_fuel+rho1*A1*W1 == rho2*A2*W2, u.kg/u.hr);
mdot_fuel = solve(eqn);