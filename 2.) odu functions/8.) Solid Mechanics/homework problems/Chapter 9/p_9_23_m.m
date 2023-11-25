%% beam
u = symunit;
b = beam;
b = b.add('reaction', 'force', 'R1', 0);
b = b.add('reaction', 'force', 'R2', 7*u.m);
b = b.add('applied', 'force', -12*u.kN, 3*u.m);
b.L = 7*u.m;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and bending moment diagrams
beam.shear_moment(m, v, [0 7], {'kN' 'm'});
subplot(2,1,1);
axis([0 7 -7 9]);
subplot(2,1,2);
axis([0 7 0 23]);

%% section properties
B = 200*u.mm;
H = 300*u.mm;
I = B*H^3/12;

%% loads at point A
M_A = m(2*u.m);
V_A = v(2*u.m);

%% stresses at point A
C = H/2;
y_A = 75*u.mm-C;
sigma_A = rewrite(-M_A*y_A/I, u.MPa);

tau_A = rewrite(-3*V_A/(2*B*H)*(1-y_A^2/C^2), u.MPa);

%% mohr stresses at point A
sigmax = sigma_A;
sigmay = sym(0);
tauxy = tau_A;
theta = (90+25)*u.deg;

[sigmaxm sigmaym tauxym] = beam.mohr(sigmax, sigmay, tauxy, theta);
sigmaxm = collect(sigmaxm, u.MPa);
sigmaym = collect(sigmaym, u.MPa);
tauxym = collect(tauxym, u.MPa);

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);