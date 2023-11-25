%% given
u = symunit;
y = [12.0 4.0 82.0 2.0]/100;
M = [44.01 31.999 28.013 28.01]*u.kg/u.kmol;

%% molar mass of mixture
c = double(y.*M/sum(y.*M));
Mmix = sum(y.*M);