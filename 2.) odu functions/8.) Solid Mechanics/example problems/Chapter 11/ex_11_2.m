%% allowable stresses
u = symunit;
sigma_allow = 9*u.MPa;
tau_allow = 0.6*u.MPa;

%% beam
b = beam; %(kN,m)
b = b.add('reaction', 'force', 'Ra', u.m);
b = b.add('reaction', 'force', 'Rb', 4*u.m);
b = b.add('distributed', 'force', -12*u.kN/u.m, [0 4]*u.m);
b.L = 4*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear and moment diagrams
beam.shear_moment(m, v, [0 4], {'kN' 'm'});
subplot(2,1,1);
axis([0 4 -22 26]);
subplot(2,1,2);
axis([0 4 -8 13]);

%% section properties
Ao = sym('Ao');
B(Ao) = Ao;
H = 1.5*B;
I = B*H^3/12;
A = B*H;

%% maximum loads
assume(0 < x & x < b.L & in(x, 'real'));
xmax = solve(v == 0, x);
M_max = m(xmax);
V_max = subs(expression(v,1), x, u.m);

%% maximum stresses
C = H/2;
sigma_max = rewrite(M_max, u.kN*u.mm)*C/I;
tau_max = 3*V_max/(2*A);

%% minimum beam dimension
assume(Ao > 0 & in(Ao, 'real'));
clear Ao_min;
Ao_min.bend = solve(sigma_max == rewrite(sigma_allow, u.kN/u.mm^2));
Ao_min.bend = simplify(Ao_min.bend);
Ao_min.shear = solve(tau_max == rewrite(tau_allow, u.kN/u.mm^2));
Ao_min.shear = simplify(Ao_min.shear);

Ao_min_vals = [Ao_min.bend Ao_min.shear];
loc = sigma_max(Ao_min_vals) <= sigma_allow & ...
      tau_max(Ao_min_vals) <= tau_allow;
Ao_min.limit = Ao_min_vals(isAlways(loc));

setassum(old_assum, 'clear');
clear old_assum Ao_min_vals loc;