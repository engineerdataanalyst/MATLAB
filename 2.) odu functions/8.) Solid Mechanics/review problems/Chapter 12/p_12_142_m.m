%% beam
wo = sym('wo');
L = sym('L');
wf = findpoly(1, 'thru', [0 -wo], [L 0]);

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'moment', 'Ma', 0);
b = b.add('reaction', 'force', 'Rb', L);
b = b.add('reaction', 'moment', 'Mb', L);
b = b.add('distributed', 'force', wf, [0 L]);

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 1], [wo L], 1);
subplot(2,1,1);
axis([0 1 -0.23 0.43]);
subplot(2,1,2);
axis([0 1 -0.058 0.032]);