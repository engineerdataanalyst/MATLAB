%% given
u = symunit;
A1 = 0.006*u.ft^2;
V1 = 100*u.ft/u.s;
A2 = 0.006*u.ft^2;
Vcv = 20*u.ft/u.s;
rho = 1.940*u.slug/u.ft^3;
theta = 45*u.deg;
g = 32.2*u.ft/u.s^2;
l = 1*u.ft;

%% conservation of mass
syms W2;
W1 = V1-Vcv;
W2 = W1;

%% conservation of momentum (x-direction)
W1x = W1;
W2x = W2*cos(theta);
Rx = rewrite(simplify(rho*(W1x*W1*A1*-1+W2x*W2*A2)), u.lbf);

%% conservation of momentum (z-direction)
syms Rz;
W2z = W2*sin(theta);
Ww = rho*g*A1*l;
Rz = solve(rewrite(Rz-Ww == rho*W2z*W2*A2, u.lbf));

%% magnitude and direction of force on vane
Fa = simplify(sqrt(Rx^2+Rz^2), 'IgnoreAnalyticConstraints', true);
phi = atand(Rz/Rx)*u.deg;