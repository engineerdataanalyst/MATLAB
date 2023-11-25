%% section properteis
u = symunit;
B = 50*u.mm;
H = 150*u.mm;
I = B*H^3/12;
A = B*H;

%% loads at point A
V_A = 30*u.kN;
M_A = -(30*u.kN)*(300*u.mm);

%% stresses at point A
y_A = (150/2-50)*u.mm;
sigma_A = rewrite(-M_A*y_A/I, u.MPa);

C = 150*u.mm/2;
tau_A = rewrite(-3*V_A/(2*A)*(1-y_A^2/C^2), u.MPa);

%% mohr stresses at point A
sigmax = sigma_A;
sigmay = sym(0);
tauxy = tau_A;

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);
beam.mohr_plot(sigmax, sigmay, tauxy, {'MPa'});