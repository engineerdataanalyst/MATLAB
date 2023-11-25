%% beam
wo = sym('wo');
L = sym('L');

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', L);
b = b.add('reaction', 'force', 'Rc', 2*L);
b = b.add('reaction', 'force', 'Rd', 3*L);
b = b.add('distributed', 'force', -wo, [0 3*L]);
b.L = 3*L;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 3], [wo L], 1);
subplot(2,1,1);
axis([0 3 -0.8 0.8]);
subplot(2,1,2);
axis([0 3 -0.12 0.098]);