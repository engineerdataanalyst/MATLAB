%% given
syms U umax r R;
u1(r) = U;
u2(r) = umax*(1-(r/R)^2);

%% conservation of mass
A1 = pi*R^2;
U(umax) = solve(-A1*u1+int(u2*2*sympi*r, r, 0, R), U);
V2avg(umax) = int(u2*2*sympi*r, r, 0, R)/A1;