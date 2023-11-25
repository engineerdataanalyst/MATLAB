%% given
u = symunit;
Aj = 0.01*u.m^2;
Vj = 30*u.m/u.s;
A1 = 0.075*u.m^2;
A2 = 0.075*u.m^2;
V2 = 6*u.m/u.s;
rho = 1000*u.kg/u.m^3;

%% average velocitiess
syms Vew;
Aew = A1-Aj;
V1avg(Vew) = simplify((Aew*Vew+Aj*Vj)/A1);
V2avg = V2;

%% conservation of mass
Vew = solve(A1*V1avg == A2*V2avg);
Qew = rewrite(Aew*Vew, [u.l u.s]);