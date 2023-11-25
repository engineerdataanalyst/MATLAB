%% allowable stresses
u = symunit;
sigma_allow = 20*u.ksi;
tau_allow = 10*u.ksi;

%% beam
b = beam; %(kip,ft)
b = b.add('reaction', 'force', 'R', 3*u.ft);
b = b.add('reaction', 'moment', 'M', 3*u.ft);
b = b.add('applied', 'force', -3*u.kip, 0);
b = b.add('applied', 'moment', 3*u.kip*u.ft, 1.5*u.ft);
b.L = 3*u.ft;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear moment diagrams
beam.shear_moment(m, v, [0 3], {'kip' 'ft'});
subplot(2,1,2);
axis([0 3 -13.5 1.5]);

%% section properties
D = sym('D');
R(D) = D/2;
I = pi*R^4/4;

%% maximum loads
M_max = m(b.L);
V_max = v(0);

%% maximum stresses
C = R;
sigma_max = rewrite(abs(M_max), u.kip*u.in)*C/I;

Q_max = (4*R/(3*pi))*(pi*R^2/2);
t_min(D) = D;
tau_max = abs(V_max)*Q_max/(I*t_min);

%% minimum beam height
assume(D > 0 & in(D, 'real'));
clear D_min;
D_min.bend = solve(sigma_max == rewrite(sigma_allow, u.kip/u.in^2));
D_min.bend = simplify(D_min.bend);
D_min.shear = solve(tau_max == rewrite(tau_allow, u.kip/u.in^2));
D_min.shear = simplify(D_min.shear);

D_min_vals = [D_min.bend D_min.shear];
loc = sigma_max(D_min_vals) <= sigma_allow & ...
      tau_max(D_min_vals) <= tau_allow;
D_min.limit = D_min_vals(isAlways(loc));

setassum(old_assum, 'clear');
clear old_assum D_min_vals loc;