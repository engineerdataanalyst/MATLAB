%% given
u = symunit;
p134a_1 = 1.0*u.MPa;
T134a_1 = 60*u.Celsius;
mdot134a = 0.2*u.kg/u.s;
p134a_2 = 0.95*u.MPa;
T134a_2 = 35*u.Celsius;
TH20_1 = 10*u.Celsius;
TH20_2 = 20*u.Celsius;

%% state 1 (R-134a, superheated)
h134a_1 = 441.89*u.kJ/u.kg;

%% state 2 (R-134a, saturated liquid)
h134a_2 = 249.10*u.kJ/u.kg;

%% state 1 (water, saturated liquid)
hH20_1 = 41.99*u.kJ/u.kg;

%% state 2 (water, saturated liquid)
hH20_2 = 83.94*u.kJ/u.kg;

%% first law of thermodynamics
syms mdotH20;
eqn = mdot134a*h134a_1+mdotH20*hH20_1 == ...
      mdot134a*h134a_2+mdotH20*hH20_2;
mdotH20 = solve(eqn);