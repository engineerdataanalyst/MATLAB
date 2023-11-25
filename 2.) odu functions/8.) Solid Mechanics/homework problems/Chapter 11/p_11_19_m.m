%% beam
u = symunit;
x = sym('x');
E = sym('E');

old_assum = assumptions;
clearassum;
args = {'mode' 'factor'};
wf1 = findpoly(1, 'thru', [0 -15*u.N/u.m], ...
                          [1.5*u.m -25*u.N/u.m], args{:});
wf2 = findpoly(1, 'thru', [1.5*u.m -25*u.N/u.m], ...
                          [3*u.m -15*u.N/u.m], args{:});

b = beam;
b = b.add('reaction', 'force', 'Ra', 0);
b = b.add('reaction', 'force', 'Rb', 3*u.m);
b = b.add('distributed', 'force', wf1, [0 1.5]*u.m);
b = b.add('distributed', 'force', wf2, [1.5 3]*u.m, [false true]);
b.L = 3*u.m;

%% section properties
Do = 15*u.mm;
Di = sym('Di');
Ro = Do/2;
Ri(Di) = Di/2;

yc = 4/(3*sympi)*[Ro; Ri; -Ri; -Ro];
Ac = sympi/2*[Ro^2; -Ri^2; -Ri^2; Ro^2];
Ic = (sympi/8-8/(9*sympi))*[Ro^4; -Ri^4; -Ri^4; Ro^4];

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
b.I = rewrite(sum(In), u.m);

%% elastic curve
[y(x,E,Di) dy(x,E,Di) m v w r] = b.elastic_curve(x, 'factor');

%% shear and moment diagram
beam.shear_moment(m, v, [0 3], {'N' 'm'});
subplot(2,1,1);
axis([0 3 -40 40]);
subplot(2,1,2);
axis([0 3 0 27]);

%% maximum loads
M_max = m(1.5*u.m);
V_max = v(0);

%% maximum stresses
C = Ro;
b.I = simplify(rewrite(b.I, u.mm));
sigma_max = simplify(rewrite(M_max, u.N*u.mm)*C/b.I);

Q_max(Di) = simplify(sum(index(Qn, 1:2)));
t_min(Di) = Do-Di;
tau_max = simplify(V_max*Q_max/(b.I*t_min));

%% minimum inner diameter
sigma_allow = 167*u.MPa;
tau_allow = 97*u.MPa;

assume(0 < Di & Di < Do & in(Di, 'real'));
clear Di_min;

Di_min.bend = solve(sigma_max == rewrite(sigma_allow, u.N/u.mm^2));
Di_min.bend = simplify(Di_min.bend);

Di_min.shear = solve(tau_max == rewrite(tau_allow, u.N/u.mm^2));
Di_min.shear = simplify(separateUnits(Di_min.shear))*u.mm;

Di_min_vals = [Di_min.bend Di_min.shear];
loc = sigma_max(Di_min_vals) <= sigma_allow & ...
      tau_max(Di_min_vals) <= tau_allow;
Di_min.limit = Di_min_vals(isAlways(loc));

%% clean up
setassum(old_assum, 'clear');
clear args old_assum;
clear Di_min_vals loc;