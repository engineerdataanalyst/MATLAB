%% beam
u = symunit;
b = beam;
b = b.add('reaction', 'force', 'R1', 0);
b = b.add('reaction', 'force', 'R2', 3*u.m);
b = b.add('applied', 'force', -30*u.kN, u.m);
b.L = 3*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

assume(old_assum);
clear old_assum;

%% shear and bending moment diagram
beam.shear_moment(m, v, [0 3], {'kN' 'm'});
subplot(2,1,1);
axis([0 3 -15 25]);
subplot(2,1,2);
axis([0 3 0 23]);

%% section properties
yc = [45; 20; -70; -145]*u.mm;
Ac = [100*10; 10*40; 10*140; 100*10]*u.mm^2;
Ic = [100*10^3; 10*40^3; 10*140^3; 100*10^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% loads at point A
M_A = m(0.5*u.m);
V_A = v(0.5*u.m);

%% stresses at point A
y_A = 50*u.mm;
sigma_A = rewrite(-M_A*y_A/I, u.MPa);

Q_A = sum(Qn(1:2));
t_A = 10*u.mm;
tau_A = rewrite(V_A*Q_A/(I*t_A), u.MPa);