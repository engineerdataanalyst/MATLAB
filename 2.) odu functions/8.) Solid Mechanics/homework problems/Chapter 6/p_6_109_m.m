%% section properties
u = symunit;
Bo = 10*u.in;
Ho = 16*u.in;
Bi = 8*u.in;
Hi = 14*u.in;
Iy = (Ho*Bo^3-Hi*Bi^3)/12;
Iz = (Bo*Ho^3-Bi*Hi^3)/12;

%% bending stresses
M = 20*u.kip*u.ft;
My = -M*sin(45*u.deg);
Mz = -M*cos(45*u.deg);

y = [-Ho/2; Ho/2; Ho/2; -Ho/2];
z = [Bo/2; Bo/2; -Bo/2; -Bo/2];

[sigma alpha] = beam.unsymmetric(My, Mz, Iy, Iz, y, z);
sigma = rewrite(sigma, u.ksi);
sigma_max = symmax(abs(sigma));