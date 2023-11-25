syms rho phi theta
integrand = (sin(phi)*cos(theta))^2*sin(phi);
integral = int(int(integrand, phi, 0, sympi), theta, 0, 2*sympi);