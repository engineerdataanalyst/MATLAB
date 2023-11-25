%% given
u = symunit;
Vj = 40*u.m/u.s;
Dj = 30*u.mm;
theta = 30*u.deg;
rho = 1.23*u.kg/u.m^3;

%% part A
% conservation of momentum (y-direction)
Vjy = Vj*sin(theta);
Aj = sympi/4*Dj^2;
Fa_a = rewrite(rho*-Vjy*Vj*-Aj, u.N);

%% part B
% conservation of mass
syms A2 A3;
eqn = sym.zeros(2,1);
eqn(1) = rewrite(Aj*Vj == (A2+A3)*Vj, [u.mm u.s]);
% conservation of momentum (x-direction)
Vjx = Vj*cos(theta);
eqn(2) = rewrite(0 == Vjx*Vj*-Aj+Vj*Vj*A2-Vj*-Vj*-A3, [u.mm u.s]);
[A2 A3] = solve(eqn);
A2 = simplify(A2);
A3 = simplify(A3);
% mass flow rate fractions
mdot2_mdotj = double(A2/Aj);
mdot3_mdotj = double(A3/Aj);

%% part C
Vcv = 10*u.m/u.s;
Wj = Vj-Vcv;
Wjy = Wj*sin(theta);
Fa_c = rewrite(rho*-Wjy*Wj*-Aj, u.N);