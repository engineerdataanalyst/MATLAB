syms x y z
zfun(x,y) = x+y^2;
integrand = y*Norm(gradient(z-formula(zfun), [x y z]));
integrand = combine(integrand);
integral = int(int(integrand, x, 0, 1), y, 0, 2);