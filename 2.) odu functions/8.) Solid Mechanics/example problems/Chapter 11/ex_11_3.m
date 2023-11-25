%% allowable stresses
u = symunit;
sigma_allow = 12*u.MPa;
tau_allow = 0.8*u.MPa;

%% beam
b = beam;
b = b.add('reaction', 'force', 'Rb', 0);
b = b.add('reaction', 'force', 'Rd', 4*u.m);
b = b.add('distributed', 'force', -0.5*u.kN/u.m, [0 2]*u.m);
b = b.add('applied', 'force', -1.5*u.kN, 2*u.m);
b.L = 4*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and moment diagrams
beam.shear_moment(m, v, [0 4], {'kN' 'm'});
subplot(2,1,1);
axis([0 4 -1.5 2]);
subplot(2,1,2);
axis([0 4 0 2.35]);

%% section properties
yc = [200/2; 200+30/2]*u.mm;
Ac = [30*200; 200*30]*u.mm^2;
Ic = [30*200^3; 200*30^3]*u.mm^4/12;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = sum(In);

%% maximum loads
M_max = m(2*u.m);
V_max = v(0);

%% maximum stresses
C = symmax([yn 230*u.mm-yn]);
sigma_max = rewrite(M_max*C/I, u.MPa);

Q_max = (yn/2)*(30*u.mm*yn);
t_min = 30*u.mm;
tau_max = rewrite(V_max*Q_max/(I*t_min), u.kPa);

safe_beam = isAlways(sigma_max <= sigma_allow & ...
                     tau_max <= tau_allow);

%% maximum spacing of nails
F_nail = 1.50*u.kN;
V_nail = abs(v([0; b.L]));
Q_nail = Qn(2);
q_nail = rewrite(V_nail*Q_nail/I, u.kN/u.m);
t_nail = rewrite(F_nail./q_nail, u.mm);