%% section properties
u = symunit;
zc = [200-20/2; 0; -(200-20/2)]*u.mm;
Acz = [(200-20)*20; 20*400; (200-20)*20]*u.mm^2;
Icy = [(200-20)*20^3; 20*400^3; (200-20)*20^3]*u.mm^4/12;

yc = [(200-20)/2; 200-20/2; (200-20)/2]*u.mm;
Acy = [20*(200-20); 400*20; 20*(200-20)]*u.mm^2;
Icz = [20*(200-20)^3; 400*20^3; 20*(200-20)^3]*u.mm^4/12;

[zn Qny Iny] = beam.neutral_axis(zc, Acz, Icy);
Iy = sum(Iny);
[yn Qnz Inz] = beam.neutral_axis(yc, Acy, Icz);
Iz = sum(Inz);

%% bending stresses
M = 520*u.N*u.m;
My = M*5/13;
Mz = -M*12/13;

y = [-yn; 200*u.mm-yn];
z = [-200; 200]*u.mm;

[sigma alpha] = beam.unsymmetric(My, Mz, Iy, Iz, y, z);
sigma = rewrite(sigma, u.MPa);