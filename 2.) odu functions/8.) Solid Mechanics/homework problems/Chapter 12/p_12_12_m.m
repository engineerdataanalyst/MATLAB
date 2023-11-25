%% beam
P = sym('P');
a = sym('a');
L = sym('L');

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', L);
b = b.add('applied', 'force', -P, a);
b = b.add('applied', 'force', -P, L-a);

%% elastic curve
old_assum = assumptions;
setassum(0 < a & a < L/2, 'clear');

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum, 'clear');
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 4], [P a L], [1 1 4]);
subplot(2,1,1);
axis([0 4 -1.35 1.35]);
subplot(2,1,2);
axis([0 4 0 1.15]);