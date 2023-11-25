%% allowable stresses
u = symunit;
sigma_allow = 12*u.MPa;
tau_allow = 1.5*u.MPa;

%% beam
b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', u.m);
b = b.add('reaction', 'force', 'Rb', 3*u.m);
b = b.add('applied', 'moment', 5*u.kN*u.m, 0);
b = b.add('applied', 'force', -50*u.kN, 2*u.m);
b = b.add('applied', 'moment', -5*u.kN*u.m, 4*u.m);
b.L = 4*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear moment diagrams
beam.shear_moment(m, v, [0 4], {'kN' 'm'});
subplot(2,1,1);
axis([0 4 -33 33]);
subplot(2,1,2);
axis([0 4 -9 24]);

%% section properties
B = sym('B');
H(B) = 3*B;
I = B*H^3/12;
A = B*H;

%% maximum loads
M_max = m(2*u.m);
V_max = v(1.5*u.m);

%% maximum stresses
C = H/2;
sigma_max = rewrite(M_max, u.kN*u.mm)*C/I;
tau_max = 3*V_max/(2*A);

%% minimum beam height
assume(B > 0 & in(B, 'real'));
clear B_min;
B_min.bend = solve(sigma_max == rewrite(sigma_allow, u.kN/u.mm^2));
B_min.bend = simplify(B_min.bend);
B_min.shear = solve(tau_max == rewrite(tau_allow, u.kN/u.mm^2));
B_min.shear = simplify(B_min.shear);

B_min_vals = [B_min.bend B_min.shear];
loc = sigma_max(B_min_vals) <= sigma_allow & ...
      tau_max(B_min_vals) <= tau_allow;
B_min.limit = B_min_vals(isAlways(loc));

setassum(old_assum, 'clear');
clear old_assum B_min_vals loc;