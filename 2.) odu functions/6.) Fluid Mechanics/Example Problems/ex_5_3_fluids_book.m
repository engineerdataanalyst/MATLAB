%% given
u = symunit;
mdot1 = 600*u.lbm/u.hr;
mdot3 = 3.0*u.lbm/u.hr;

%% conservation of mass
syms mdot2;
mdot2 = solve(-mdot1+mdot2+mdot3 == 0);