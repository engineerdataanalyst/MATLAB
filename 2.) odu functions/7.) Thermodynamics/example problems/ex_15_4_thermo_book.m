%% given
% problem (p. 716)
u = symunit;
V1 = 30*u.m/u.s;
p1 = 350*u.kPa;
T1 = rewrite(25*u.Celsius, u.K, 'Temperature', 'absolute');
V2 = 7*u.m/u.s;
p2 = 600*u.kPa;
R = 0.287*u.kJ/(u.kg*u.K);
cp = 1.004*u.kJ/(u.kg*u.K);
cv = 0.717*u.kJ/(u.kg*u.K);

%% part A (reversible process, incompressible?????????)
syms p2_rev
v1 = 0.001003*u.m^3/u.kg;
eqn_a = simplify(v1*(p2_rev-p1)+(V2^2-V1^2)/2 == 0);
p2_rev = rewrite(solve(eqn_a), u.kPa);

%% part B (actual process, incompressible)
% enthalpy change
syms h2_h1;
eqn_b = simplify(h2_h1+(V2^2-V1^2)/2 == 0);
h2_h1 = rewrite(solve(eqn_b), [u.kJ u.kg]);
% internal energy change
u2_u1 = h2_h1-rewrite(v1*(p2-p1), [u.kJ u.kg]);
% entropy change
s2_s1 = u2_u1/T1;