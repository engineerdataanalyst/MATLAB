%% given
% (problem: p. 407)
u = symunit;
p_condenser = 10*u.kPa;
p_boiler = 2*u.MPa;

%% state 1 (saturated liquid)
p1 = p_condenser;
v1 = 0.001010*u.m^3/u.kg;
h1 = 191.81*u.kJ/u.kg;
s1 = 0.6492*u.kJ/(u.kg*u.K);
 
%% state 2 (saturated liquid)
p2 = p_boiler;
s2 = s1;
w_12 = rewrite(-v1*(p2-p1), [u.kJ u.kg]);
h2 = h1-w_12;

%% state 3 (saturated vapor)
p3 = p_boiler;
h3 = 2799.51*u.kJ/u.kg;
s3 = 6.3408*u.kJ/(u.kg*u.K);
q_23 = h3-h2;

%% state 4 (liquid-vapor mis)
p4 = p_condenser;
s4 = s3;
sf4 = 0.6492*u.kJ/(u.kg*u.K);
sfg4 = 7.5010*u.kJ/(u.kg*u.K);
x4 = (s4-sf4)/sfg4;
hf4 = 191.81*u.kJ/u.kg;
hfg4 = 2392.82*u.kJ/u.kg;
h4 = hf4+x4*hfg4;
w_34 = h3-h4;

%% cycle efficiency
wnet = w_12+w_34;
qH = q_23;
nth = double(wnet/qH);