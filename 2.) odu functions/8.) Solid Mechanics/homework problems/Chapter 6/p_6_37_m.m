%% beam
u = symunit;
wf1 = findpoly(1, 'thru', [0 -50*u.kN/u.m], [4.5*u.m 0]);
wf2 = findpoly(1, 'thru', [4.5*u.m 0], [9*u.m -50*u.kN/u.m]);

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 9*u.m);
b = b.add('distributed', 'force', wf1, [0 4.5]*u.m);
b = b.add('distributed', 'force', wf2, [4.5 9]*u.m, [false true]);
b.L = 9*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 9], {'kN' 'm'});
subplot(2,1,1);
axis([0 9 -150 150]);
subplot(2,1,2);
axis([0 9 0 180]);