syms a0 b0 a1 b1 a2 b2;
syms ui vi uj vj uk vk;
syms xi yi xj yj xk yk;
syms x y;
syms t E A nu;

u(x,y) = a0+a1*x+a2*y;
v(x,y) = b0+b1*x+b2*y;

[a eqn] = deal(sym.zeros(3,1));
eqn(1) = u(xi,yi) == ui;
eqn(3) = u(xj,yj) == uj;
eqn(4) = u(xk,yk) == uk;
[a(1) a(2) a(3)] = solve(eqn, a0, a1, a2);
b = subs(a, [ui uj uk], [vi vj vk]);

u = subs(u, [a0 a1 a2], a.');
u = collect(u, [ui uj uk]);
v = subs(v, [b0 b1 b2], b.');
v = collect(v, [vi vj vk]);

At = 1/2*det([1 xi yi; 1 xj yj; 1 xk yk]);
N = coeffs(u(x,y), [uk uj ui]).';
B = [diff(N(1),x)     0        diff(N(2),x)      0       diff(N(3),x)      0; ...
          0       diff(N(1),y)      0       diff(N(2),y)      0       diff(N(3),y); ...
     diff(N(1),y) diff(N(1),x) diff(N(2),y) diff(N(2),x) diff(N(3),y) diff(N(3),x)];
D = E/(1-nu^2)*[1 nu 0; nu 1 0; 0 0 (1-nu)/2];
K = t*A*B.'*D*B;