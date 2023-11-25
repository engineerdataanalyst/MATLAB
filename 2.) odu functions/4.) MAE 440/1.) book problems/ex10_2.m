%% given
Q = 4000; %W/m^3
k = 0.8; %W/(m-C)
h = 20; %W/(m^2-C)
Tinf = 30; %C
L = 6.25e-2; %m

%% stiffness matrix
Ke = cell(2,1);
kL = k/L;

Ke{1} = [kL -kL 0; ...
        -kL  kL 0; ...
          0    0  0];                   

Ke{2} = [0  0   0; ...
         0  kL -kL; ...
         0 -kL  kL+h];

K = Ke{1}+Ke{2};

%% force vector
Fe = cell(2,1);
Fe{1} = [Q*L/2; Q*L/2; 0];
Fe{2} = [h*Tinf; Q*L/2; Q*L/2];
F = Fe{1}+Fe{2};

%% solution
T = K^-1*F;



