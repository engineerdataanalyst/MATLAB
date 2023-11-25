%% section properties
u = symunit;
B = 300*u.mm;
H = 200*u.mm;
Iy = B*H^3/12;
Iz = H*B^3/12;

%% bending stresses
M = 50*u.kN*u.m;
My = M*4/5;
Mz = M*3/5;

y = [-B/2; B/2];
z = [H/2; H/2];

[sigma alpha] = beam.unsymmetric(My, Mz, Iy, Iz, y, z);
sigma = rewrite(sigma, u.MPa);