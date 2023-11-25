%% given
u = symunit;
p1 = 100*u.psi;
T1 = 520*u.Rankine;
p2 = 14.7*u.psi;
gamma = 1.4;
R = 53.34*u.ft*u.lbf/(u.lbm*u.Rankine);

%% second law of thermodynamics (part a)
syms Va positive;
rho = p1/(R*T1);
eqna = p1/rho == p2/rho+Va^2/2;
Va = solve(eqna);
Va = simplify(rewrite(Va, u.ft/u.s), 'IgnoreAnalyticConstraints', true);

%% second law of thermodynamics (part b)
syms Vb positive;
rho1 = rho;
rho2 = rho1*(p2/p1)^(1/gamma);
eqnb = gamma/(gamma-1)*p1/rho1 == gamma/(gamma-1)*p2/rho2+Vb^2/2;
Vb = solve(eqnb);
Vb = simplify(rewrite(Vb, u.ft/u.s), 'IgnoreAnalyticConstraints', true);
clearassum;