%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1(x) = -12*u.kN/u.m;
wf2 = findpoly(1, 'thru', [3*u.m -12*u.kN/u.m], [4.5*u.m 0], args{:});

b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 3*u.m);
b = b.add('distributed', 'force', wf1, [0 3]*u.m);
b = b.add('distributed', 'force', wf2, [3 4.5]*u.m, [false true]);
b.L = 4.5*u.m;

%% section properties
D = 90*u.mm;
R = D/2;
b.I = rewrite(pi*R^4/4, u.m);

%% elastic curve
[y(x,E) dy(x,E) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 4.5], {'kN' 'm'});
subplot(2,1,1);
axis([0 4.5 -23.5 20.5]);
subplot(2,1,2);
axis([0 4.5 -6.4 13.3]);

%% maximum  moment
assume(0 < x & x < b.L & in(x, 'real'));
xmax = solve(v == 0, x);
M_val = m(xmax);
M_max = vpa(M_val, 4) %#ok
M_max = M_val;

%% maximum bending stress
C = R;
b.I = rewrite(b.I, u.mm);
sigma_val = rewrite(M_max*C/b.I, u.MPa);
sigma_max = vpa(sigma_val, 5) %#ok
sigma_max = sigma_val;

%% clean up
setassum(old_assum, 'clear');
clear args old_assum;