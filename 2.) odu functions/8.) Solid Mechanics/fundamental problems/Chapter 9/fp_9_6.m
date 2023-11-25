%% beam
u = symunit;
wf1 = findpoly(1, 'thru', [0 0], [3*u.m -8*u.kN/u.m]);
wf2 = findpoly(1, 'thru', [3*u.m -8*u.kN/u.m], [6*u.m 0]);

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.m);
b = b.add('distributed', 'force', wf1, [0 3]*u.m);
b = b.add('distributed', 'force', wf2, [3 6]*u.m, [false true]);
b.L = 6*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagram
beam.shear_moment(m, v, [0 6], {'kN' 'm'});
subplot(2,1,1);
axis([0 6 -15 15]);
subplot(2,1,2);
axis([0 6 0 27]);

%% section properties
B = 150*u.mm;
I = B^4/12;
A = B^2;

%% loads at point C
M_C = m(3*u.m);
V_C = v(3*u.m);

%% stresses at point C
sigma_C = sym(0);
tau_C = rewrite(-3*V_C/(2*A), u.MPa);

%% maximum shear stress
sigmax = sigma_C;
sigmay = sym(0);
tauxy = tau_C;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);