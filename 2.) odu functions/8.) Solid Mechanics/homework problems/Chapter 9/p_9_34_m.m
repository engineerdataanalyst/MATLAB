%% beam
u = symunit;
b = beam; %(lbf,in)
b = b.add('reaction', 'force', 'R1', 0);
b = b.add('reaction', 'force', 'R2', 48*u.in);
b = b.add('applied', 'force', -300*u.lbf, 36*u.in);
b.L = 48*u.in;

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

setassum(old_assum);
clear old_assum;

%% shear and moment diagrams
beam.shear_moment(m, v, [0 48], {'lbf' 'in'});
subplot(2,1,1);
axis([0 48 -265 115]);
subplot(2,1,2);
axis([0 48 0 3000]);

%% section properties
D = 2*u.in;
R = D/2;
I = pi*R^4/4;
A = pi*R^2;

%% loads at point A
M_A = m(24*u.in);
V_A = v(24*u.in);
F_A = 3000*u.lbf;

%% stresses at point A
clear sigma_A;
sigma_A.axial = rewrite(F_A/A, u.psi);

y_A = R;
sigma_A.bend = rewrite(-M_A*y_A/I, u.psi);

tau_A = sym(0);

%% mohr stresses at point A
sigmax = sigma_A.axial+sigma_A.bend;
sigmay = sym(0);
tauxy = tau_A;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);