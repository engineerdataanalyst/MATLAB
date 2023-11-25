%% given
% (problem 141)
u = symunit;
m_obj = 25*u.kg;
V1_obj = 25*u.m/u.s;
V2_obj = 0;
dt_obj = 5*u.s;
m_wat = 0.5*u.kg;
T1_wat = 20*u.Celsius;
p_wat = 100*u.kPa;

%% displacement work
a_obj = (V2_obj-V1_obj)/dt_obj;
F_obj = rewrite(m_obj*a_obj, u.N);
dx_obj = V1_obj*dt_obj+1/2*a_obj*dt_obj^2;
W_obj = rewrite(F_obj*dx_obj, u.kJ);
u2_u1_obj = -W_obj; % dunno this for sure.....

%% water
syms u2_wat;
u1_wat = 83.94*u.kJ/u.kg;
u2_wat = solve(u2_u1_obj == m_wat*(u2_wat-u1_wat), u2_wat);
T2_wat = interp1([83.94 104.86], [20 25], ...
                 double(removeUnits(u2_wat)))*u.Celsius;