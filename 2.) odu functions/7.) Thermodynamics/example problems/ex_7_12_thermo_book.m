%% given
u = symunit;
p1 = 100*u.kPa;
T1 = 300*u.K;
p2 = 150*u.kPa;
p2s = 150*u.kPa;
ncomp = 0.70;
gamma = 1.4;
cp = 1.004*u.kJ/(u.kg*u.K);
R = 0.287*u.kJ/(u.kg*u.K);

%% state 2_ideal
T2s = T1*(p2s/p1)^((gamma-1)/gamma);
ws = cp*(T1-T2s);

%% state 2
syms w T2;
w = solve(ncomp == ws/w);
T2 = solve(w == cp*(T1-T2));