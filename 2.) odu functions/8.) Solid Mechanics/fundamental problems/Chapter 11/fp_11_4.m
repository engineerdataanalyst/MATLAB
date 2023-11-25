%% allowable stresses
u = symunit;
sigma_allow = 2*u.ksi;
tau_allow = 200*u.psi;

%% beam
b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 6*u.ft);
b = b.add('distributed', 'force', -1.5*u.kip/u.ft, [0 6]*u.ft);
b.L = 6*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear moment diagrams
beam.shear_moment(m, v, [0 6], {'kip' 'ft'});
subplot(2,1,1);
axis([0 6 -5.75 5.75]);
subplot(2,1,2);
axis([0 6 0 7.75]);

%% section properties
B = 4*u.in;
H = sym('H');
I(H) = B*H^3/12;
A(H) = B*H;

%% maximum loads
M_max = m(b.L/2);
V_max = v(0);

%% maximum stresses
C = H/2;
sigma_max = rewrite(M_max, u.kip*u.in)*C/I;
tau_max = 3*rewrite(V_max, u.lbf)/(2*A);

%% minimum beam height
assume(H > 0 & in(H, 'real'));
clear H_min;
H_min.bend = solve(sigma_max == rewrite(sigma_allow, u.kip/u.in^2));
H_min.bend = simplify(H_min.bend);
H_min.shear = solve(tau_max == rewrite(tau_allow, u.lbf/u.in^2));
H_min.shear = simplify(H_min.shear);

H_min_vals = [H_min.bend H_min.shear];
loc = sigma_max(H_min_vals) <= sigma_allow & ...
      tau_max(H_min_vals) <= tau_allow;
H_min.limit = H_min_vals(isAlways(loc));

setassum(old_assum, 'clear');
clear old_assum H_min_vals loc;