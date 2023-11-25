%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rc', 4*u.m);
b = b.add('reaction', 'force', 'Rd', 6*u.m);
b = b.add('reaction', 'force', 'Rf', 10*u.m);
b = b.add('applied', 'force', -3*u.kN, 2*u.m);
b = b.add('distributed', 'force', -0.8*u.kN/u.m, [3 7]*u.m);
b = b.add('applied', 'force', -3*u.kN, 8*u.m);
b.L = 10*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 10], {'kN' 'm'});
subplot(2,1,1);
axis([0 10 -3.2 3.2]);
subplot(2,1,2);
axis([0 10 -2.1 2.9]);

%% clean up
setassum(old_assum);
clear args old_assum;