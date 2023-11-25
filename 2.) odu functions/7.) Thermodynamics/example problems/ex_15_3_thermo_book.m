%% given
u = symunit;
Ai = 0.2*u.m^2;
Vi = 100*u.m/u.s;
pi = 95*u.kPa;
Ae = 0.1*u.m^2;
Ve = 450*u.m/u.s;
pe = 125*u.kPa;
mdot_air = 20*u.kg/u.s;
AF = 50; % air-fuel ratio
po = 100*u.kPa;

%% conservation of mass
mdot_fuel = mdot_air/AF;
mdoti = mdot_air;
mdote = mdot_air+mdot_fuel;

%% conservation of momentum
syms Rx;
eqn = rewrite(mdote*Ve-mdoti*Vi == (pi-po)*Ai-(pe-po)*Ae+Rx, u.N);
Rx = solve(eqn);