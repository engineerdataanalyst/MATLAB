%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 0], [3*u.m -10*u.kN/u.m], args{:});
wf2 = findpoly(1, 'thru', [3*u.m -10*u.kN/u.m], [6*u.m 0], args{:});

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.m);
b = b.add('applied', 'force', -10*u.kN, 3*u.m);
b = b.add('distributed', 'force', wf1, [0 3]*u.m);
b = b.add('distributed', 'force', wf2, [3 6]*u.m, [false true]);
b.L = 6*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagrams
beam.shear_moment(m, v, [0 6], {'kN' 'm'});
subplot(2,1,1);
axis([0 6 -25 25]);
subplot(2,1,2);
axis([0 6 0 50]);

%% clean up
setassum(old_assum);
clear args old_assum;