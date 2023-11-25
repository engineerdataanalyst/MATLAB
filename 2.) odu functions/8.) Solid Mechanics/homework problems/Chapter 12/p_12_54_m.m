%% beam
u = symunit;
x = sym('x');
wf1 = findpoly(1, 'thru', [0 0], [9*u.ft -6*u.kip/u.ft]);
wf2(x) = -6*u.kip/u.ft;

b = beam;
b = b.add('reaction', 'force', 'Ra', 9*u.ft);
b = b.add('reaction', 'force', 'Rb', 24*u.ft);
b = b.add('distributed', 'force', wf1, [0 9]*u.ft);
b = b.add('distributed', 'force', wf2, [9 24]*u.ft, [false true]);
b.L = 24*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 24], {'kip' 'ft'});
subplot(2,1,1);
axis([0 24 -55 65]);
subplot(2,1,2);
axis([0 24 -105 160]);