%% given
u = symunit;
Q = 0.6*u.L/u.s;
D1 = 16*u.mm;
D2 = 5*u.mm;
mn = 0.1*u.kg;
p1 = 464*u.kPa;
rho = 999*u.kg/u.m^3;
g = 9.81*u.m/u.s^2;
h = 30*u.mm;

%% conservation of mass
A1 = sympi/4*D1^2;
A2 = sympi/4*D2^2;
w1 = rewrite(Q/A1, u.m/u.s);
w2 = rewrite(Q/A2, u.m/u.s);

%% fluid statics
p2 = 0;

%% conservation of momentum
syms Fa clear;
Vw = 1/3*sympi*(D1^2/4+D1*D2/4+D2^2/4)*h;
Wn = rewrite(mn*g, u.N);
Ww = rewrite(rho*Vw*g, u.N);
eqn = Fa-Wn-Ww-p1*A1+p2*A2 == rho*(-w1*A1*-w1*1-w2*A2*-w2*-1);
eqn = rewrite(eqn, u.N);
Fa = solve(eqn);