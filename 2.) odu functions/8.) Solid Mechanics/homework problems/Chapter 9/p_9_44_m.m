%% beam
u = symunit;
wf = findpoly(1, 'thru', [0 0], [0.9*u.m -150*u.kN/u.m]);

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'R', 0.9*u.m);
b = b.add('reaction', 'moment', 'M', 0.9*u.m);
b = b.add('distributed', 'force', wf, [0 0.9]*u.m);
b.L = 0.9*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 0.9], {'kN' 'm'});
subplot(2,1,1);
axis([0 0.9 -75 10]);
subplot(2,1,2);
axis([0 0.9 -23 3]);

%% section properties
yc = [200/2+10/2; 0; -200/2-10/2]*u.mm;
Ac = [150*10; 10*200; 150*10]*u.mm^2;
Ic = [150*10^3; 10*200^3; 150*10^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% loads at point A
M_A = m(0.6*u.m);
V_A = v(0.6*u.m);

%% bending and shear stresses at point A
y_A = -200*u.mm/2;
sigma_A = rewrite(-M_A*y_A/I, u.MPa);

Q_A = abs(Qn(3));
t_A = 10*u.mm;
tau_A = rewrite(-V_A*Q_A/(I*t_A), u.MPa);

%% mohr stresses at point A
sigmax = sigma_A;
sigmay = sym(0);
tauxy = tau_A;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);