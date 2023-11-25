%% beam
u = symunit;
b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 1.5*u.m);
b = b.add('applied', 'force', -60*u.kN, 0.5*u.m);
b.L = 1.5*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagram
beam.shear_moment(m, v, [0 1.5], {'kN' 'm'});
subplot(2,1,1);
axis([0 1.5 -30 50]);
subplot(2,1,2);
axis([0 1.5 0 23]);

%% section properties
yc = [95; 0; -95]*u.mm;
Ac = [100*10; 10*180; 100*10]*u.mm^2;
Ic = [100*10^3; 10*180^3; 100*10^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% loads at point A
M_A = m(0.5*u.m);
V_A = v(0.5*u.m);

%% stresses at point C
y_A = 90*u.mm;
sigma_A = rewrite(-M_A*y_A/I, u.MPa);

Q_A = Qn(1);
t_A = 10*u.mm;
tau_A = rewrite(-V_A*Q_A/(I*t_A), u.MPa);

%% maximum shear stress
sigmax = sigma_A;
sigmay = sym(0);
tauxy = tau_A;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);