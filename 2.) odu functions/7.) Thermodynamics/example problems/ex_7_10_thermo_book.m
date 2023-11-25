%% given
u = symunit;
p1 = 1*u.MPa;
T1 = 300*u.Celsius;
p2 = 15*u.kPa;
w = 600*u.kJ/u.kg;

%% state 1 (super-heated steam)
h1 = 3051.15*u.kJ/u.kg;
s1 = 7.1228*u.kJ/(u.kg*u.K);

%% state 2_ideal (saturated vapor)
s2 = s1;
s2f = 0.7548*u.kJ/(u.kg*u.K);
s2fg = 7.2536*u.kJ/(u.kg*u.K);
x = double((s2-s2f)/s2fg);
h2f = 225.91*u.kJ/u.kg;
h2fg = 2373.14*u.kJ/u.kg;
h2s = h2f+x*h2fg;

%% isentropic efficiency
nth = double(w/(h1-h2s));