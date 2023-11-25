%% given
u = symunit;
z1 = 420*u.ft;
g = 32.2*u.ft/u.s^2;
cv = 1*u.Btu/(u.lbm*u.Rankine);

%% first law of thermodynamics
syms T2_T1;
eqn = rewrite(rewrite(cv*T2_T1-g*z1 == 0, [u.ft u.lbf]), u.Rankine);
T2_T1 = solve(eqn);