syms x y z u v h a;
F(x,y,z) = [z x y];
r = [a*cos(u) a*sin(u) v];
dr = simplify(cross(diff(r,u),diff(r,v)));
integrand = Dot(F(r(1),r(2),r(3)),dr);
integral = int(int(integrand, v, 0, h), u, 0, sympi/2);