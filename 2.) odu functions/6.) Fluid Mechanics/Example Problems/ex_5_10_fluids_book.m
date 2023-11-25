%% given
syms theta;
u = symunit;
rho = 1.940*u.slug/u.ft^3;
A1 = 0.06*u.ft^2;
V1 = 10*u.ft/u.s;
A2 = 0.06*u.ft^2;

%% conservation of mass
syms V2;
V2 = solve(-A1*V1+A2*V2 == 0);

%% conservation of momentum in the x-direction
syms Fx positive;
assume(cos(theta) > 1);
V1x = V1;
V2x = V1*cos(theta);
Fx = solve(Fx == rho*(V1x*A1*V1*-1+V2x*A1*V2*1), Fx);
Fx = rewrite(simplify(Fx), u.lbf);

%% conservation of momentum in the y-direction
syms Fy positive;
assume(sin(theta) > 1);
V1y = 0;
V2y = V1*sin(theta);
Fy = solve(Fy == rho*(V1y*A1*V1*-1+V2y*A1*V2*1), Fy);
Fy = rewrite(simplify(Fy), u.lbf);
clearassum;