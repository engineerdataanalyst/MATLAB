%% section properties
u = symunit;
yc = [150; 100; 100; -100; -100; -150]*u.mm;
Ac = [140*30; 30*200; 30*200; 30*200; 30*200; 140*30]*u.mm^2; 
Ic = [140*30^3; 30*200^3; 30*200^3; 30*200^3; 30*200^3; 140*30^3]*u.mm^4/12; 

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% maximum shear stress
V = 20*u.kN;
Q_max = sum(Qn(1:3));
t_min = 60*u.mm;
tau_max = rewrite(V*Q_max/(I*t_min), u.MPa);