%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.m);
b = b.add('applied', 'force', -10*u.kN, 2*u.m);
b = b.add('applied', 'force', -10*u.kN, 4*u.m);
b = b.add('applied', 'moment', -15*u.kN*u.m, 6*u.m);
b.L = 6*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 6], {'kN' 'm'});
subplot(2,1,1);
axis([0 6 -15.5 10]);
subplot(2,1,2);
axis([0 6 -18 18]);

%% clean up
setassum(old_assum);
clear args old_assum;