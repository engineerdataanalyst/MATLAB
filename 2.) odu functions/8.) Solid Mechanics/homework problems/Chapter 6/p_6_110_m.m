%% allowable stress
u = symunit;
sigma_allow = 12*u.ksi;

%% section properties
Bo = 10*u.in;
Ho = 16*u.in;
Bi = 8*u.in;
Hi = 14*u.in;
Iy = (Ho*Bo^3-Hi*Bi^3)/12;
Iz = (Bo*Ho^3-Bi*Hi^3)/12;

%% maximum bending stresses
M = sym('M');
My(M) = -M*sin(45*u.deg);
Mz(M) = -M*cos(45*u.deg);

y = [-Ho/2; Ho/2; Ho/2; -Ho/2];
z = [Bo/2; Bo/2; -Bo/2; -Bo/2];

[sigma alpha] = beam.unsymmetric(My, Mz, ...
                                 rewrite(Iy, u.ft), rewrite(Iz, u.ft), ...
                                 rewrite(y, u.ft), rewrite(z, u.ft));

%% maximum bending moments
old_assum = assumptions;
setassum(M > 0 & in(M, 'real'), 'clear');

M_max = sym.zeros(4,1);
sigma_max = cell(4,1);
lhs = rewrite(sigma_allow, u.kip/u.ft^2);
for k = 1:4
  rhs = abs(index(sigma, k)); 
  M_max(k) = solve(lhs == rhs);
  sigma_max{k} = rewrite(sigma(M_max(k)), u.ksi);
end

f = @(x) all(isAlways(abs(x) <= sigma_allow));
loc = cellfun(f, sigma_max);
M_limit = unique(M_max(loc));

setassum(old_assum, 'clear');
clear old_assum lhs rhs k f loc;