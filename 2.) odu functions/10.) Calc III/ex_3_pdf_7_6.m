%% compute the integrand
syms x y z;
F(x,y,z) = [x y z];
zfun = plane([1 0 0], [0 2 0], [0 1 1]);
f = z-zfun;
integrand(x,y) = sum(formula(F).*gradient(formula(f)).');
integrand = subs(integrand, z, zfun);

%% compute the surface integral
yfun1 = findpoly(1, 'thru', [1 0], [0 1]);
yfun2 = findpoly(1, 'thru', [1 0], [0 2]);
integral = int(int(integrand, y, yfun1, yfun2), x, 0, 1);