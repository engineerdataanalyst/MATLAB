%% section properties
u = symunit;
B = 30*u.mm;
H = 60*u.mm;
I = B*H^3/12;
A = B*H;

%% loads at point B
F_B = 4*u.kN;
clear sigma_B;
sigma_B.axial = rewrite(F_B/A, u.MPa);

M_B = -(2*u.kN)*(2*u.m);
y_B = H/2;
sigma_B.bend = rewrite(-M_B*y_B/I, u.MPa);

tau_B = sym(0);

%% mohr stresses
sigmax = sigma_B.axial+sigma_B.bend;
sigmay = sym(0);
tauxy = sym(0);

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);
beam.mohr_plot(sigmax, sigmay, tauxy, {'MPa'});