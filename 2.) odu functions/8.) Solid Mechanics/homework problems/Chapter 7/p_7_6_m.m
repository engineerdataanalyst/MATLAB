%% section properties
u = symunit;
yc = [15; 30+250/2; 30+250+15]*u.mm;
Ac = [125*30; 25*250; 200*30]*u.mm^2;
Ic = [125*30^3; 25*250^3; 200*30^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
clear Q;
Q.A = Qn(3);
Q.B = abs(Qn(1));
I = sum(In);

%% loads
V = 15*u.kN;
t = 25*u.mm;

%% shear stress
clear tau;
tau.A = rewrite(V*Q.A/(I*t), u.MPa);
tau.B = rewrite(V*Q.B/(I*t), u.MPa);