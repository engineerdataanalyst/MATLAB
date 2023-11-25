%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 5*u.ft);
b = b.add('reaction', 'force', 'Rb', 15*u.ft);
b = b.add('distributed', 'force', -2*u.kip/u.ft, [0 5]*u.ft);
b = b.add('applied', 'moment', -30*u.kip*u.ft, 10*u.ft);
b.L = 15*u.ft;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagrams
beam.shear_moment(m, v, [0 15], {'kip' 'ft'});
subplot(2,1,1);
axis([0 15 -11.5 1]);
subplot(2,1,2);
axis([0 15 -32 6.75]);

%% clean up
setassum(old_assum);
clear old_assum;