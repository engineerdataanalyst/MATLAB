syms x y z;
F(x,y,z) = [x y z];
r = [x y 1-2*x+2*y];
dr = simplify(cross(diff(r, x),diff(r, y)));
integrand = simplify(Dot(F(r(1),r(2),r(3)),dr));
integral = int(int(integrand, y, 0, (2*x-1)/2), x, 0, 1/2);