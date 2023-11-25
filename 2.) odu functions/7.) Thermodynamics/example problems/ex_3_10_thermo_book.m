%% given
% ammonia (problem: page 107, tables: page 794)
u = symunit;
m = 0.5*u.kg;
T1 = -20*u.Celsius;
x1 = 0.25;
T2 = 20*u.Celsius;

%% state 1 (liquid-vapor mix)
% quality
syms v1;
vf1 = 0.001504*u.m^3/u.kg;
vfg1 = 0.62184*u.m^3/u.kg;
v1 = solve(x1 == (v1-vf1)/vfg1);
V1 = m*v1;

%% state 2 (saturated vapor)
V2 = 1.41*V1;
v2 = V2/m;