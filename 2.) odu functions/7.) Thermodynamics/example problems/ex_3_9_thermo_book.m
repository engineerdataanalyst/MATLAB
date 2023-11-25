%% given
u = symunit;
V = 5*u.m^3;
Vf1 = 0.05*u.m^3;
Vg1 = 4.95*u.m^3;

%% state 1
% quality
vf1 = 0.001043*u.m^3/u.kg;
vg1 = 1.69400*u.m^3/u.kg;
mf1 = Vf1/vf1;
mg1 = Vg1/vg1;
uf1 = 417.33*u.kJ/u.kg;
ug1 = 2506.06*u.kJ/u.kg;
U1 = mf1*uf1+mg1*ug1;

%% state 2
m = mf1+mg1;
v2 = V/m;
v2doub = double(removeUnits(v2));
u2 = interp1([0.09963 0.08875], [2600.26 2601.98], v2doub)*u.kJ/u.kg;
U2 = m*u2;
clear v2doub;

%% first law of thermodynamics
Q = U2-U1;