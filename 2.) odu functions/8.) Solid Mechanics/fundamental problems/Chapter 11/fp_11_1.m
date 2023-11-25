%% allowable stresses
u = symunit;
sigma_allow = 10*u.MPa;
tau_allow = u.MPa;

%% beam
b = beam; %(kN,m)
b = b.add('reaction', 'force', 'R', 2*u.m);
b = b.add('reaction', 'moment', 'M', 2*u.m);
b = b.add('applied', 'force', -6*u.kN, 0);
b = b.add('applied', 'force', -6*u.kN, u.m);
b.L = 2*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear moment diagrams
beam.shear_moment(m, v, [0 2], {'kN' 'm'});
subplot(2,1,1);
axis([0 2 -13 -5]);
subplot(2,1,2);
axis([0 2 -20 2.5]);

%% section properties
Ao = sym('Ao');
B(Ao) = Ao;
H = 2*B;
I = B*H^3/12;
A = B*H;

%% maximum loads
M_max = m(b.L);
V_max = v(b.L);

%% maximum stresses
C = H/2;
sigma_max = rewrite(abs(M_max), u.kN*u.mm)*C/I;
tau_max = 3*abs(V_max)/(2*A);

%% minimum beam height
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