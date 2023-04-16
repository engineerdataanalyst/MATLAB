%% variables
x = sym('x');
y = sym('y');

%% equations
eqn = sym.zeros(11,1);
eqn(1) = x/y^3 == 1;
eqn(2) = x^2+y^3 == 4;
eqn(3) = x^2+y^2 == 2;
eqn(4) = 2*y^3+4*x^2-y == x^6;
eqn(5) = 7*y^2+sin(3*x) == 12-y^4;
eqn(6) = exp(x)-sin(y) == x;
eqn(7) = 4*x^2*y^7-2*x == x^5+4*y^3;
eqn(8) = cos(x^2+2*y)+x*exp(y^2) == 1;
eqn(9) = tan(x^2*y^4) == 3*x+y^2;
eqn(10) = x^4+y^2 == 3;
eqn(11) = y^2*exp(2*x) == 3*y+x^2;

%% implicit derivatives
dy = sym.zeros(11,1);
for k = 1:11
  dy(k) = simplifyFraction(impdiff(eqn(k), x, y));
end

%% tangent lines
ytan = sym.nan(11,1);
ytan(10) = subs(dy(10), [x y], [1 -sqrt(2)])*(x-1)-sqrt(2);
ytan(11) = subs(dy(11), [x y], [0 3])*x+3;
