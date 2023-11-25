syms x y z rho phi theta;
F(x,y,z) = [z y x];
xp = sin(phi)*cos(theta);
yp = sin(phi)*sin(theta);
zp = cos(phi);
r = [xp yp zp];
integrand = Dot(F(xp,yp,zp),cross(diff(r,phi),diff(r,theta)));
integral = int(int(integrand, phi, 0, sympi), theta, 0, 2*sympi);