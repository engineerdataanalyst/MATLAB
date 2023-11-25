%% beam
u = symunit;
x = sym('x');
wf1(x) = -8*u.kip/u.ft;
wf2 = findpoly(1, 'thru', [6*u.ft -8*u.kip/u.ft], [15*u.ft 0]);

b = beam;
b = b.add('reaction', 'force', 'Ra', 6*u.ft);
b = b.add('reaction', 'force', 'Rb', 15*u.ft);
b = b.add('distributed', 'force', wf1, [0 6]*u.ft);
b = b.add('distributed', 'force', wf2, [6 15]*u.ft, [false true]);
b.L = 15*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 15], {'kip' 'ft'});
subplot(2,1,1);
axis([0 15 -58 52]);
subplot(2,1,2);
axis([0 15 -160 20]);