%% given
u = symunit;
mdot1 = 9*u.slug/u.s;
D1 = 4*u.ft;
V1 = 300*u.ft/u.s;
V2 = 900*u.ft/u.s;
V3 = 900*u.ft/u.s;
theta = 30*u.deg;
rho = 0.00238*u.slug/u.ft^3;

%% conservation of mass
syms A2;
A1 = sympi*D1^2/4;
A2 = solve(A1*V1 == 2*A2*V2);

%% conservation of momentum (x-direction)
syms Fx;
V2x = V2*cos(theta);
V3x = V3*cos(theta);
Fx = rho*(V1*V1*-A1-V2x*V2*A2-V3x*V3*A2);
Fx = rewrite(simplify(Fx), u.lbf); % retired!!!!!