%% beam
u = symunit;
x = sym('x');
wf(x) = -1/8*x^2*u.kip/u.ft^3;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'moment', 'Ma', 0);
b = b.add('distributed', 'force', wf, [0 8]*u.ft);
b.L = 8*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 8], {'kip' 'ft'});
subplot(2,1,1);
axis([0 8 -4 25]);
subplot(2,1,2);
axis([0 8 -146 20]);