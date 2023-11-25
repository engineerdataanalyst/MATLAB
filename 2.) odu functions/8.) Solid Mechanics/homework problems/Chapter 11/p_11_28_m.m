%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;

b = beam;
b = b.add('reaction', 'force', 'R1', 2*u.in);
b = b.add('reaction', 'force', 'R2', 8*u.in);
b = b.add('applied', 'force', -15*u.lbf, 0);
b = b.add('distributed', 'force', -6*u.lbf/u.in, [2 8]*u.in);
b = b.add('applied', 'force', -10*u.lbf, 10*u.in);
b.L = 10*u.in;

%% section properties
B = sym('B');
H(B) = 2*B;
b.I = B*H^3/12;
A = B*H;

%% elastic curve
[y(x,E,B) dy(x,E,B) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 10], {'lbf', 'in'});
subplot(2,1,1);
axis([0 10 -21 26]);
subplot(2,1,2);
axis([0 10 -35 8]);

%% maximum loads
M_max = m(2*u.in);
V_max = subs(expression(v,2), x, 2*u.in);

%% maximum stresses
C = H/2;
sigma_max = abs(M_max)*C/b.I;
tau_max = 3*V_max/(2*A);

%% minimum inner diameter
sigma_allow = 735*u.psi;
tau_allow = 400*u.psi;

assume(B > 0 & in(B, 'real'));
clear B_min;

B_min.bend = solve(sigma_max == rewrite(sigma_allow, u.lbf/u.in^2));
B_min.bend = simplify(B_min.bend);

B_min.shear = solve(tau_max == rewrite(tau_allow, u.lbf/u.in^2));
B_min.shear = simplify(B_min.shear);

B_min_vals = [B_min.bend B_min.shear];
loc = sigma_max(B_min_vals) <= sigma_allow & ...
      tau_max(B_min_vals) <= tau_allow;
B_min.limit = B_min_vals(isAlways(loc));

%% clean up
setassum(old_assum, 'clear');
clear old_assum;
clear B_min_vals loc;