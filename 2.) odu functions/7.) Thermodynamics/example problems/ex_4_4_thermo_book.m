%% given
u = symunit;
p1 = 0.6*u.MPa;
T1 = 200*u.Celsius;
V1 = 50*u.m/u.s;
p2 = 0.15*u.mPa;
V2 = 600*u.m/u.s;

%% state 1 (superheated)
h1 = 2850.12*u.kJ/u.kg;

%% first law of thermodynamics
syms h2;
h2 = solve(h1+V1^2/2 == h2+V2^2/2);
h2 = rewrite(h2, u.kJ/u.kg);

%% state 2 (liquid-vapor mix)
h2f = 467.08*u.kJ/u.kg;
h2fg = 2226.46*u.kJ/u.kg;
x = double((h2-h2f)/h2fg);