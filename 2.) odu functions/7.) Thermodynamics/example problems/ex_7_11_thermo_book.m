%% given
u = symunit;
T1 = 1600*u.K;
T2 = 830*u.K;
p2 = 100*u.kPa;
p2s = 100*u.kPa;
nth = 0.85;
R = 0.287*u.kJ/(u.kg*u.K);

%% state 1
h1 = 1757.33*u.kJ/u.kg;
s1 = 8.69051*u.kJ/(u.kg*u.K);

%% state 2
h2 = interp1([800 850], [822.20 877.40], 830)*u.kJ/u.kg;
s2 = interp1([800 850], [7.88514 7.95207], 830)*u.kJ/(u.kg*u.K);

%% isentropic efficiency
syms h2s p1;
h2s = solve(nth == (h1-h2)/(h1-h2s));
s2s = interp1([692.12 713.56], [7.70903 7.74010], ...
              double(removeUnits(h2s)))*u.kJ/(u.kg*u.K);
T2s = interp1([692.12 713.56], [680 700], ...
              double(removeUnits(h2s)))*u.K;
p1 = solve(0 == s2s-s1-R*log(p2s/p1));