%% given
u = symunit;
D1 = 1*u.in;
V1 = 100*u.ft/u.s;
V2 = 100*u.ft/u.s;
V3 = 100*u.ft/u.s;
theta = 45*u.deg;
rho = 1.94*u.slug/u.ft^3;

%% part A (conservation of mass)
A1 = sympi*D1^2/4;
% A1*V1 == A2*V2+A3*V3
% A1*V1 == A2*V1+A3*V1
% A1*V1 == (A2+A3)*V1
% A1 == A2+A3

%% conservation of momentum (x-direction)
% Fx == rho*(V1*V1*-A1-V2x*V2*A2-V3x*V3*A3);
% Fx == rho*(-A1*V1^2-(V2*cos(theta)*V2*A2)-(V3*cos(theta)*V3*A3)
% Fx == rho*(-A1*V1^2-(V1*cos(theta)*V1*A2)-(V1*cos(theta)*V1*A3)
% Fx == rho*(-A1*V1^2-V1^2*cos(theta)*A2-V1^2*cos(theta)*A3)
% Fx == -rho*(A1+(A2+A3)*cos(theta))*V1^2
% Fx == rho*(A1+A1*cos(theta))*V1^2
% Fx == rho*A1*(1+cos(theta))*V1^2
Fx = rewrite(rho*A1*(1+cos(theta))*V1^2, u.lbf);