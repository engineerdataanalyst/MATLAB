%% section properties
u = symunit;
yc = [10+90/2; 10+90/2; 0; -10-90/2; -10-90/2]*u.mm;
Ac = [20*90; 20*90; 300*20; 20*90; 20*90]*u.mm^2;
Ic = [20*90^3; 20*90^3; 300*20^3; 20*90^3; 20*90^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% shear stress at point A
V_A = 100*u.kN;
Q_A = sum(Qn(1));
t_A = 20*u.mm;
tau_A = rewrite(V_A*Q_A/(I*t_A), u.MPa);