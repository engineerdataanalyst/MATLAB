%% beam
u = symunit;
x = sym('x');
E = sym('E');
wo = sym('wo');

old_assum = assumptions;
clearassum;

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 2*u.m);
b = b.add('distributed', 'force', -wo, [0 1]*u.m);
b.L = 2*u.m;

%% section properties
yc = [150/2; 150+25/2]*u.mm;
Ac = [25*150; 150*25]*u.mm^2;
Ic = [25*150^3; 150*25^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
b.I = rewrite(sum(In), u.m);

%% elastic curve
[y(x,E,wo) dy(x,E,wo) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 2], {'kN' 'm'}, wo, 1);
subplot(2,1,1);
axis([0 2 -0.5 1]);
subplot(2,1,2);
axis([0 2 0 0.32]);

%% maximum loads
assume(0 < x & x < b.L & in(x, 'real'));
xmax = solve(v == 0, x);
M_max(wo) = m(xmax);
V_max(wo) = v(0);

%% maximum stresses
C = symmax([yn (150+25)*u.mm-yn]);
b.I = rewrite(b.I, u.mm);
sigma_max = rewrite(M_max*C/b.I, u.m);

Q_max = (yn/2)*(25*u.mm*yn);
t_min = 25*u.mm;
tau_max = rewrite(V_max*Q_max/(b.I*t_min), u.m);

%% maximum distributed force
sigma_allow = 15*u.MPa;
tau_allow = 1.5*u.MPa;

assume(wo > 0 & in(wo, 'real'));
clear wo_max;

wo_max.bend = solve(sigma_max == rewrite(sigma_allow, u.kN/u.m^2));
wo_max.bend = simplify(wo_max.bend);

wo_max.shear = solve(tau_max == rewrite(tau_allow, u.kN/u.m^2));
wo_max.shear = simplify(wo_max.shear);

wo_max_vals = [wo_max.bend wo_max.shear];
loc = sigma_max(wo_max_vals) <= sigma_allow & ...
      tau_max(wo_max_vals) <= tau_allow;
wo_max.limit = wo_max_vals(isAlways(loc));

%% clean up
setassum(old_assum, 'clear');
clear old_assum;
clear wo_max_vals loc;