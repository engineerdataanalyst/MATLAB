%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 0], [4.5*u.m -5*u.kN/u.m], args{:});
wf2 = findpoly(1, 'thru', [4.5*u.m 0], [9*u.m -5*u.kN/u.m], args{:});

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 9*u.m);
b = b.add('distributed', 'force', wf1, [0 4.5]*u.m);
b = b.add('distributed', 'force', wf2, [4.5 9]*u.m, [false true]);
b.L = 9*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 9], {'kN' 'm'});
subplot(2,1,1);
axis([0 9 -15 12]);
subplot(2,1,2);
axis([0 9 0 30]);

%% clean up
setassum(old_assum);
clear args old_assum;