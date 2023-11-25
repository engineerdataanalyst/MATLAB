%% given
u = symunit;
Q1 = 10*u.ft^3/u.s;
rho1 = 0.00238*u.slug/u.ft^3;
D2 = 1.2*u.in;
rho2 = 0.0035*u.slug/u.ft^3;
V2 = 700*u.ft/u.s;
Volcv = 20*u.ft^3;

%% part A
A2 = sympi*D2^2/4;
mdotcs = simplify(-rho1*Q1+rho2*A2*V2);

%% part B
syms rhodotcv;
mdotcv(rhodotcv) = rhodotcv*Volcv;
rhodotcv = simplify(solve(mdotcv+mdotcs == 0));