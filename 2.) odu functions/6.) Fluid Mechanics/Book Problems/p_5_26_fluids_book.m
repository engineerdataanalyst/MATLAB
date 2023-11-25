%% given
u = symunit;
Q1 = 20*u.gal/u.min;
hcone = 5*u.ft;
dcone = 5*u.ft;
rho = 1.94*u.slug/u.ft^3;

%% flux of mass out of control surface
mdotcs = simplify(-rho*Q1);

%% mass flow rate into control volume
syms hfun(t) h t;
rcone = dcone/2;
rfun(t) = rcone*hfun/hcone;
Volcv = sympi*rfun^2*hfun/3;
dVolcv_dt = diff(Volcv);
mdotcv = rho*dVolcv_dt;
eqn = simplify(mdotcv+mdotcs == 0);

%% time required to fill up cone
t = solve(subs(eqn, [hfun diff(hfun)], [hcone hcone/t]));

%% DIDNT' EVEN HAVE TO DO ALL THIS!!!!!!!