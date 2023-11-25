%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 0], [3*u.ft -12*u.kip/u.ft], args{:});
wf2(x) = -12*u.kip/u.ft;

b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.ft);
b = b.add('distributed', 'force', wf1, [0 3]*u.ft);
b = b.add('distributed', 'force', wf2, [3 6]*u.ft, [false true]);
b.L = 6*u.ft;

%% section properties
B = sym('B');
H(B) = 1.5*B;
b.I = B*H^3/12;
A = B*H;

%% elastic curve
[y(x,E,B) dy(x,E,B) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 6], {'kip' 'ft'});
subplot(2,1,1);
axis([0 6 -40 30]);
subplot(2,1,2);
axis([0 6 0 51]);

%% maximum loads
assume(0 < x & x < b.L & in(x, 'real'));
xmax = solve(v == 0, x);
M_max = m(xmax);
V_max = v(b.L);

%% maximum stresses
C = H/2;
sigma_max = rewrite(M_max, u.kip*u.in)*C/b.I;
tau_max = 3*abs(V_max)/(2*A);

%% minimum beam dimension
sigma_allow = 1.20*u.ksi;
tau_allow = 100*u.psi;

assume(B > 0 & in(B, 'real'));
clear B_min;

B_min.bend = solve(sigma_max == rewrite(sigma_allow, u.kip/u.in^2));
B_min.bend = simplify(B_min.bend);

B_min.shear = solve(tau_max == rewrite(tau_allow, u.kip/u.in^2));
B_min.shear = simplify(B_min.shear);

B_min_vals = [B_min.bend B_min.shear];
loc = sigma_max(B_min_vals) <= sigma_allow & ...
      tau_max(B_min_vals) <= tau_allow;
B_min.limit = B_min_vals(isAlways(loc));

%% clean up
setassum(old_assum, 'clear');
clear args old_assum;
clear B_min_vals loc;