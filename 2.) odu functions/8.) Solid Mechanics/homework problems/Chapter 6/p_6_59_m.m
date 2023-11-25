%% allowable bending stress
u = symunit;
clear sigma_allow;
sigma_allow.ten = 24*u.ksi;
sigma_allow.com = -22*u.ksi;

%% section properties
yc = [4; 2]*u.in;
Ac = [6*8; -sympi*1.5^2]*u.in^2;
Ic = [6*8^3/12; -sympi*1.5^4/4]*u.in^4;

[yn Qn In] = beam.neutral_axis(yc, Ac, Ic);
I = simplify(sum(In));

%% maximum bending stresses
M = sym('M');
clear C;
C.ten = -yn;
C.com = 8*u.in-yn;
sigma_max.ten(M) = -M*simplify(rewrite(C.ten/I, u.ft));
sigma_max.com(M) = -M*simplify(rewrite(C.com/I, u.ft));

%% maximum bending moments
old_assum = assumptions;
setassum(M > 0 & in(M, 'real'), 'clear');

clear M_max;
M_max.ten = solve(sigma_max.ten == rewrite(sigma_allow.ten, u.kip/u.ft^2));
M_max.ten = simplify(M_max.ten);
M_max.com = solve(sigma_max.com == rewrite(sigma_allow.com, u.kip/u.ft^2));
M_max.com = simplify(M_max.com);

M_max_vals = [M_max.ten M_max.com];
loc = sigma_max.ten(M_max_vals) <= sigma_allow.ten & ...
      abs(sigma_max.com(M_max_vals)) <= abs(sigma_allow.com);
M_max.limit = M_max_vals(isAlways(loc));

setassum(old_assum, 'clear');
clear M_max_vals loc;