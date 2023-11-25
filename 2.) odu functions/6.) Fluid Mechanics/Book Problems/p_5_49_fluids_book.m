%% given
u = symunit;
V1 = 700*u.ft/u.s;
V2 = 1640*u.ft/u.s;
A1 = 10*u.ft^2;
p1 = 11.4*u.psi;
T1 = 480*u.Rankine;
p2 = 0;
R = 53.34*u.ft*u.lbf/(u.lbm*u.Rankine);
gamma = 1.4;

%% conservation of mass
syms A2;
rho = rewrite(p1/(R*T1), [u.slug u.ft^3]);
rho2 = rho*(p2/p1)^(1/gamma);

%% conservation of momentum
syms Ft;
eqn = rewrite(Ft+(p1-p2)*A1 == rho*(V1*V1*A1*-1+rho2*V2*V2*A2), u.lbf);
Ft = solve(eqn); % retired!!!!