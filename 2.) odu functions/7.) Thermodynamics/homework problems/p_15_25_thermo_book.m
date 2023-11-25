%% given
% (problem p. 15.25)
u = symunit;
Vi = 150*u.m/u.s;
pi = 75*u.kPa;
Ti = rewrite(5*u.Celsius, u.K, 'Temperature', 'absolute');
Ai = 0.6*u.m^2;
Ve = 450*u.m/u.s;
pe = 75*u.kPa;
Te = 800*u.K;
R = 0.287*u.kJ/(u.kg*u.K);
p0 = 100*u.kPa;

%% conservation of mass
rhoi = rewrite(pi/(R*Ti), 'SI');
rhoe = rewrite(pe/(R*Te), 'SI');
mdoti = rhoi*Ai*Vi;
mdote = mdoti;

%% conservation of momentum
syms Rx;
Ae = mdote/(rhoe*Ve);
eqn = rewrite(Rx+(pi-p0)*Ai-(pe-p0)*Ae == -mdoti*Vi+mdote*Ve, u.kN);
Rx = solve(eqn);