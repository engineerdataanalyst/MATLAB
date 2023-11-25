%% given
u = symunit;
V = 20*u.m/u.s;
D = 40*u.mm;

%% volume flow rate
A = pi/4*D^2;
Q = rewrite(A*V, u.m);