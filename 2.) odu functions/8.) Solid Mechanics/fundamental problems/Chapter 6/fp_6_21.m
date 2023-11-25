%% section properties
u = symunit;
B = 6*u.in;
H = 4*u.in;
Iy = B*H^3/12;
Iz = H*B^3/12;

%% maximum bending stress
M = 50*u.lbf*u.ft;
My = M*sin(30*u.deg);
Mz = M*cos(30*u.deg);

y = [B/2; B/2; -B/2; -B/2];
z = [-H/2; H/2; -H/2; H/2];

[sigma alpha] = beam.unsymmetric(My, Mz, Iy, Iz, y, z);
sigma = rewrite(sigma, u.psi);
sigma_max = symmax(abs(sigma));