%% given
rho = 0.2836; %lb/in^3
omega = 30; %rad/s^2
g = 32.2*12; %in/s^2
E = 10^7; %psi
A = 0.6; %in^2
L = 21; %in

%% stiffness matrix and force vector
K = E*A/(3*L)*[7 -8    1   0   0; ...
              -8  16  -8   0   0; ...
               1 -8   7+7 -8   1; ...
               0  0   -8   16 -8; ...
               0  0    1  -8   7];
F = rho*L*omega^2/(2*g)*A*L*[1/6; 2/3; 1/6; 0; 0]+...
    3*rho*L*omega^2/(2*g)*A*L*[0; 0; 1/6; 2/3; 1/6];

%% elimination
Kr = K(2:5,2:5);
Fr = F(2:5);
Q = [0; Kr\Fr];
R = [K(1,:)*Q-F(1); zeros(4,1)];

%% stresses
