%% section properties
u = symunit;
yc = [100; 25; -25; -100]*u.mm;
Ac = [100^2; 300*50; 300*50; 100^2]*u.mm^2; 
Ic = [100^4; 300*50^3; 300*50^3; 100^4]*u.mm^4/12; 

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% shear stress at point A
clear Q t tau;
V = 600*u.kN;
Q.A = sum(Qn(1:2));
t.A = 300*u.mm;
tau.A = rewrite(V*Q.A/(I*t.A), u.MPa);

%% shear stress at point B
Q.B = Qn(1);
t.B = 100*u.mm;
tau.B = rewrite(V*Q.B/(I*t.B), u.MPa);