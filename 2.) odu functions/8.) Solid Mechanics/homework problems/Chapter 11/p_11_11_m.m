%% beam
u = symunit;
x = sym('x');
E = sym('E');
P = sym('P');

old_assum = assumptions;
clearassum;

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 8*u.m);
b = b.add('applied', 'force', -P, 4*u.m);
b.L = 8*u.m;

%% section properties
yc = [120/2; 120+30/2]*u.mm;
Ac = [40*120; 150*30]*u.mm^2;
Ic = [40*120^3; 150*30^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
b.I = rewrite(sum(In), u.m);

%% elastic curve
[y(x,E,P) dy(x,E,P) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 8], {'kN' 'm'}, P, 1);
subplot(2,1,1);
axis([0 8 -0.7 0.7]);
subplot(2,1,2);
axis([0 8 0 2.28]);

%% maximum loads
M_max(P) = m(4*u.m);
V_max(P) = v(0);

%% maximum stresses
C = symmax([yn (120+30)*u.mm-yn]);
b.I = rewrite(b.I, u.mm);
sigma_max = rewrite(M_max, u.mm)*C/b.I;

Q_max = (yn/2)*(40*u.mm*yn);
t_min = 40*u.mm;
tau_max = V_max*Q_max/(b.I*t_min);

%% maximum applied force
sigma_allow = 25*u.MPa;
tau_allow = 700*u.kPa;

assume(P > 0 & in(P, 'real'));
clear P_max;

P_max.bend = solve(sigma_max == rewrite(sigma_allow, u.kN/u.mm^2));
P_max.bend = simplify(P_max.bend);

P_max.shear = solve(tau_max == rewrite(tau_allow, u.kN/u.mm^2));
P_max.shear = simplify(P_max.shear);

P_max_vals = [P_max.bend P_max.shear];
loc = sigma_max(P_max_vals) <= sigma_allow & ...
      tau_max(P_max_vals) <= tau_allow;
P_max.limit = P_max_vals(isAlways(loc));

%% clean up
setassum(old_assum, 'clear');
clear old_assum;
clear P_max_vals loc;