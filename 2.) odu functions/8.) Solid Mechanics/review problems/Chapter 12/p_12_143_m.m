%% beam
u = symunit;
x = sym('x');
E = sym('E');
wo = sym('wo');
L = sym('L');

old_assum = assumptions;
clearassum;
wf = findpoly(1, 'thru', [0 0], [L -wo], 'mode', 'factor');

b = beam;
b = b.add('reaction', 'force', 'Ra', L);
b = b.add('reaction', 'moment', 'Ma', L);
b = b.add('distributed', 'force', wf, [0 L]);

%% section properties
ho = sym('ho');
t = sym('t');
h(x,ho,L) = findpoly(1, 'thru', [0 0], [L ho], 'mode', 'factor');
b.I(x,ho,t,L) = t*h^3/12;

%% elastic curve
[y(x,E,ho,t,wo,L) dy(x,E,ho,t,wo,L) ...
 m(x,wo,L) v(x,wo,L) w(x,wo,L) r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 1], [wo L], 1);
subplot(2,1,1);
axis([0 1 -0.58 0.1]);
subplot(2,1,2);
axis([0 1 -0.19 0.03]);

%% clean up
setassum(old_assum);
clear old_assum;