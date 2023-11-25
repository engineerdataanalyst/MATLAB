%% beam
u = symunit;
b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 8*u.m);
b = b.add('distributed', 'force', -12*u.kN/u.m, [0 8]*u.m);
b = b.add('applied', 'force', -30*u.kN, 3*u.m);
b.L = 8*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 8], {'kN' 'm'});
subplot(2,1,1);
axis([0 8 -77 85]);
subplot(2,1,2);
axis([0 8 0 165]);