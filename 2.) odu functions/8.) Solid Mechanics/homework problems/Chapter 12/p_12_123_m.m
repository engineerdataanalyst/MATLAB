%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 12*u.ft);
b = b.add('reaction', 'force', 'Rc', 24*u.ft);
b = b.add('applied', 'force', -12*u.kip, 6*u.ft);
b = b.add('distributed', 'force', -3*u.kip/u.ft, [12 24]*u.ft);
b.L = 24*u.ft;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 24], {'lbf' 'ft'});
subplot(2,1,1);
axis([0 24 -20 27]);
subplot(2,1,2);
axis([0 24 -49 47]);

%% clean up
setassum(old_assum);
clear args old_assum;