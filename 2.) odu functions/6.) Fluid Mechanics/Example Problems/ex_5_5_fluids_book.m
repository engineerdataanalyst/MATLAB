%% given
% (problem: p. 194)
u = symunit;
Q_wat = 9*u.gal/u.min;
rho_air = 2.38e-3*u.slug/u.ft^3;
rho_wat = 1.94*u.slug/u.ft^3;
ltub = 5*u.ft;
wtub = 2*u.ft;
htub = 1.5*u.ft;

%% flux of mass out of control surface
mdotcs_air = 0;
mdotcs_wat = rewrite(-rho_wat*Q_wat, [u.slug u.s]);

%% mass flow rate into control volume
syms h dh_dt;
dVolwat_dt = ltub*wtub*dh_dt;
mdotcv_air = 0;
mdotcv_wat = rho_wat*dVolwat_dt;

%% conservation of mass (water)
eqn = simplify(mdotcs_air+mdotcs_wat+mdotcv_air+mdotcv_wat == 0);
dh_dt = rewrite(rhs(eqn), [u.in u.min]);