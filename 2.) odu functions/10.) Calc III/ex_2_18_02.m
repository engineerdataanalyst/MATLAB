syms x y z u v h a phi theta;
F(x,y,z) = [x*z y*z z^2];
r = [a*sin(phi)*cos(theta) a*sin(phi)*sin(theta) a*cos(phi)];
dr = simplify(cross(diff(r, phi),diff(r, theta)));
integrand = simplify(Dot(F(r(1),r(2),r(3)),dr));
integral = int(int(integrand, phi, 0, sympi/2), theta, 0, sympi/2);