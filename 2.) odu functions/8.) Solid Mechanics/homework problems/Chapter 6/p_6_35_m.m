%% beam
u = symunit;
x = sym('x');
E = sym('E');
I = sym('I');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf = findpoly(1, 'thru', [3*u.m -200*u.N/u.m], ...
                         [6*u.m -400*u.N/u.m], args{:});

b = beam; %(N,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.m);
b = b.add('distributed', 'force', wf, [3 6]*u.m);
b.L = 6*u.m;

%% elastic curve
[y(x,E,I) dy(x,E,I) m v w r] = b.elastic_curve(x, 'factor');

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 6], {'N' 'm'});
subplot(2,1,1);
axis([0 6 -800 300]);
subplot(2,1,2);
axis([0 6 0 800]);

%% clean up
setassum(old_assum);
clear args old_assum;