%% beam
u = symunit;
b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 2*u.ft);
b = b.add('applied', 'force', -6*u.kip, u.ft);
b = b.add('applied', 'force', -3*u.kip, 3*u.ft);
b.L = 3*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagram
beam.shear_moment(m, v, [0 3], {'kip' 'ft'});
subplot(2,1,1);
axis([0 3 -5.7 4.4]);
subplot(2,1,2);
axis([0 3 -3.6 2.1]);

%% section properties
B = 3*u.in;
H = 6*u.in;
I = B*H^3/12;
A = B*H;

%% maximum shear stress
V_max = v(b.L/2);
tau_max = rewrite(3*abs(V_max)/(2*A), u.psi);