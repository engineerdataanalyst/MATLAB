%% given
L = 0.15; %m
k = 0.7; %W/(m-C)
T1 = 28; %C
Tinf = -15; %C
h = 40; %W/(m^2-C)

%% stiffness matrix
% ------------------------------
Ke = cell(2,1);
kL = k/L;
% ------------------------------
Ke{1} = [kL -kL 0; ...
        -kL  kL 0; ...
         0   0  0];
% ------------------------------
Ke{2} = [0  0   0; ...
         0  kL -kL; ...
         0 -kL  kL+h];
% ------------------------------
K = Ke{1}+Ke{2};

%% force vector
Fe = cell(2,1);
Fe{1} = [0; 0; 0];
Fe{2} = [0; 0; h*Tinf];
F = Fe{1}+Fe{2};

%% solution
Kr = K(2:3,2:3);
Fr = F(2:3)-K(2:3,1)*T1;
T = [T1; Kr^-1*Fr];
q = [K(1,:)*T-F(1); 0; 0];