%% given
u = symunit;
e = 0.0015*u.mm;
D = 4.0*u.mm;
V = 50*u.m/u.s;
rho = 1.23*u.kg/u.m^3;
mu = 1.79e-5*u.N*u.s/u.m^2;
L = 0.1*u.m;
g = 9.81*u.m/u.s^2;

%% friction factors
syms F;
Re = simplify(rho*V*D/mu);
f = sym.zeros(2,1);
f(1) = 64/Re;
f(2) = solve(1/sqrt(F) == -2.0*log10(e/(3.7*D)+2.51/(Re*sqrt(F))));

%% Darcy-Weisbach equation
dP = rewrite(f*L*rho*V^2/(2*D), u.kPa);