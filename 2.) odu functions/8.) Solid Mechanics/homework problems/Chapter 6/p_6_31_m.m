%% beam
wo = sym('wo');
L = sym('L');
wf1 = -wo;
wf2 = findpoly(1, 'thru', [L/2 -wo], [L 0]);

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'moment', 'Ma', 0);
b = b.add('distributed', 'force', wf1, [0 L/2]);
b = b.add('distributed', 'force', wf2, [L/2 L], [false true]);

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
axis([0 1 -0.1 0.8]);
subplot(2,1,2);
axis([0 1 -0.35 0.05]);