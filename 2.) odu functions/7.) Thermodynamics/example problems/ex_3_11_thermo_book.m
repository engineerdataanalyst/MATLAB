%% given
% ammonia (problem: page 108, tables: page 794)
u = symunit;
m = 0.1*u.kg;
P1 = 1000*u.kPa;
T1 = 500*u.Celsius;
P2 = 1000*u.kPa;
T3 = 25*u.Celsius;

%% state 1 (superheated)
% quality
v1 = 0.35411*u.m^3/u.kg;
u1 = 3124.34*u.kJ/u.kg;
V1 = m*v1;
U1 = m*u1;

%% state 2 (liquid-gas mix)
V2 = 0.5*V1;
v2 = V2/m;
vf2 = 0.001127*u.m^3/u.kg;
vfg2 = 0.19444*u.m^3/u.kg;
x2 = (v2-vf2)/vfg2;
uf2 = 761.67*u.kJ/u.kg;
ufg2 = 1821.97*u.kJ/u.kg;
u2 = uf2+x2*ufg2;
U2 = m*u2;
T2 = 179.91*u.Celsius;

%% state 3 (liquid-gas mix)
V3 = V2;
v3 = v2;
vf3 = 0.001003*u.m^3/u.kg;
vfg3 = 43.3583*u.m^3/u.kg;
x3 = (v3-vf3)/vfg3;
uf3 = 104.86*u.kJ/u.kg;
ufg3 = 2304.90*u.kJ/u.kg;
u3 = uf3+x3*ufg3;
U3 = m*u3;
P3 = 3.169*u.kPa;

%% first law of thermodynamics
W = rewrite(P1*(V2-V1), u.kJ);
Q = U3-U1+W;