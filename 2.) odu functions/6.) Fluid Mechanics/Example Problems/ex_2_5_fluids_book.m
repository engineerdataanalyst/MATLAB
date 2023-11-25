%% given
u = symunit;
gamma1 = sym('gamma1');
gamma2 = sym('gamma2');
h1 = sym('h1');
h2 = sym('h2');

%% pressures
rhs = sum([gamma1 gamma2 -gamma1].*[h1 h2 h1+h2]);
Pa_Pb(gamma1, gamma2, h1, h2) = simplify(rhs);
clear rhs;