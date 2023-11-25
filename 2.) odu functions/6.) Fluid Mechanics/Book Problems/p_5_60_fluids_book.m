%% given
u = symunit;
p1 = 0.2*u.psi;
V1 = 100*u.ft/u.s;
p2 = 0.15*u.psi;
D = 2*u.ft;
rho = 0.00238*u.slug/u.ft^3;

%% velocity profile at the downstream
syms Vmax r;
V2(r) = findpoly(1, 'thru', [0 0], [D/2 Vmax], 'var', r);

%% conservation of mass
A = sympi/4*D^2;
eqn = sym.zeros(2,1);
eqn(1) = A*V1 == int(V2*2*sympi*r, 0, D/2);
Vmax = solve(eqn(1));
V2 = subs(V2, sym('Vmax'), Vmax);

%% conservation of momentum
syms Fdrag;
eqn(2) = Fdrag+(p1-p2)*A == rho*(V1*V1*-1*A+int(V2*V2*2*sympi*r, 0, D/2));
eqn(2) = rewrite(eqn(2), u.lbf);
Fdrag = solve(eqn(2));