%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');
M = sym('M');
L = sym('L');

old_assum = assumptions;
clearassum;

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'moment', 'Ma', 0);
b = b.add('distributed', 'moment', M, [0 L]);

%% elastic curve
[y(x,E,I,M,L) dy(x,E,I,M,L) ...
 m(x,M,L) v(x,M,L) w(x,M,L) r] = b.elastic_curve(x, 'factor');

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 1], [M L], 1);
subplot(2,1,2);
axis([0 1 -0.5 1.5]);

%% clean up
setassum(old_assum);
clear old_assum;