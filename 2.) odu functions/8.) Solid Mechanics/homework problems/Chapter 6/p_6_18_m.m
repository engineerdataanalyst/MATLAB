%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'R', 0);
b = b.add('reaction', 'moment', 'M', 0);
b = b.add('distributed', 'force', -2*u.kip/u.ft, [0 6]*u.ft);
b = b.add('applied', 'force', -10*u.kip, 6*u.ft);
b = b.add('applied', 'force', -8*u.kip, 10*u.ft);
b = b.add('applied', 'moment', -40*u.kip*u.ft, 10*u.ft);
b.L = 10*u.ft;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagrams
beam.shear_moment(m, v, [0 10], {'kip' 'ft'});
subplot(2,1,1);
axis([0 10 4 34]);
subplot(2,1,2);
axis([0 10 -241 -14]);

%% clean up
setassum(old_assum);
clear old_assum;