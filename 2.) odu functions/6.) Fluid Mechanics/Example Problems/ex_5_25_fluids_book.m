%% given
u = symunit;
Wdot = 10*u.HP_UK;
z1 = 0;
z2 = 30*u.ft;
hL = 15*u.ft;
gamma = 62.4*u.lbf/u.ft^3;

%% volume flow rate
syms Q;
hs = rewrite(Wdot/(gamma*Q), u.ft);
Q = solve(z2-z1 == hs-hL);

%% power loss
Wloss = rewrite(hL*gamma*Q, u.HP_UK);