%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rd', 9*u.m);
b = b.add('applied', 'force', -55*u.kN, 3*u.m);
b = b.add('distributed', 'force', -15*u.kN/u.m, [6 9]*u.m);
b.L = 9*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagrams
beam.shear_moment(m, v, [0 9], {'kN' 'm'});
subplot(2,1,1);
axis([0 9 -65 55]);
subplot(2,1,2);
axis([0 9 0 145]);

%% clean up
setassum(old_assum);
clear old_assum;