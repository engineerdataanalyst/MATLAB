%% section properties
u = symunit;
yc = sym([0; 0; 0]);
Ac = [20*200; 20*200; (300-2*20)*20]*u.mm^2; 
Ic = [20*200^3; 20*200^3; (300-2*20)*20^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% maximum bending stress
M = 20*u.kN*u.m;
C = 200*u.mm/2;
sigma_max = rewrite(M*C/I, u.MPa);