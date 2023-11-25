%% section properties
u = symunit;
yc = [100; 75; 75; -75; -75; -100]*u.mm;
Ac = [50*200; 25*150; 25*150; 25*150; 25*150; 50*200]*u.mm^2;
Ic = [50*200^3; 25*150^3; 25*150^3; 25*150^3; 25*150^3; 50*200^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% maximum shear stress
V = 20*u.kN;
Q_max = sum(Qn(1:3));
t_min = 50*u.mm;
tau_max = rewrite(V*Q_max/(I*t_min), u.MPa);