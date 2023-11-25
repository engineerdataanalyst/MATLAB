%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 0], [3*u.ft -400*u.lbf/u.ft], args{:});
wf2(x) = -400*u.lbf/u.ft;
wf3 = findpoly(1, 'thru', [6*u.ft -400*u.lbf/u.ft], [9*u.ft 0], args{:});

b = beam; %(lbf,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 9*u.ft);
b = b.add('distributed', 'force', wf1, [0 3]*u.ft);
b = b.add('distributed', 'force', wf2, [3 6]*u.ft, [false true]);
b = b.add('distributed', 'force', wf3, [6 9]*u.ft, [false true]);
b.L = 9*u.ft;

%% section properties
B = 7.5*u.in;
H = 2*B;
b.I = rewrite(B*H^3/12, u.ft);

%% elastic curve
[y(x,E) dy(x,E) m v w r] = b.elastic_curve(x, 'factor');

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 9], {'lbf' 'ft'});
subplot(2,1,1);
axis([0 9 -1500 1500]);
subplot(2,1,2);
axis([0 9 0 3800]);

%% maximum bending moment
assume(0 < x & x < b.L & in(x, 'real'));
xmax = solve(v == 0, x);
M_max = m(xmax);

%% maximum bending stress
C = H/2;
b.I = rewrite(b.I, u.in);
sigma_max = rewrite(M_max*C/b.I, u.psi);

%% clean up
setassum(old_assum, 'clear');
clear args old_assum;