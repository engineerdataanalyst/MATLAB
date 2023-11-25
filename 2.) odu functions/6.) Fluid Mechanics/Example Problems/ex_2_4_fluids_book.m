%% given
u = symunit;
SG.oil = 0.90;
SG.Hg = 13.6;
h = [36; 6; 9]*u.in;
gamma_H20 = 62.4*u.lbf/u.ft^3;

%% air pressure
P_air = rewrite(sum([-SG.oil -SG.oil SG.Hg].*gamma_H20*h), u.psi);