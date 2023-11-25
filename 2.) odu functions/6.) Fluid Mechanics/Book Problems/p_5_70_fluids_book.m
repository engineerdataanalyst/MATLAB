%% given
u = symunit;
l = 12*u.ft;
d = 8*u.in;
rho = 10*u.lbm/u.ft^3;
Vcv = 30*u.mph;
theta = 45*u.deg;

%% conservation of mass
W1 = 0-(-Vcv);
W2 = W1;

%% conservation of momentum (x-direction)
syms Fx;
A1 = rewrite(l*d, u.ft);
A2 = A1;
W2x = W2*cos(theta);
Fx = rho*(W1*W1*A1*-1-W2x*W2*A2);
Fx = rewrite(simplify(Fx), u.lbf);

%% conservation of momentum (y-direction)
syms Fy;
W2y = W2*sin(theta);
Fy = rho*W2y*W2*A2;
Fy = rewrite(simplify(Fy), u.lbf);