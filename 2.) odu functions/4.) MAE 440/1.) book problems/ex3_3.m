%% part a
E = 30e6; %psi
rho = 0.2836; %lb/in^3
P = 100; %lb
A = [5.25; 3.75]; %in^2
L = 12; %in

%% part b/c
K = E/L*[A(1)   -A(1)     0; ...
        -A(1) A(1)+A(2) -A(2); ...
          0     -A(2)    A(2)];
F = [rho*A(1)*L/2; ...
     rho*(A(1)+A(2))*L/2+P; ...
     rho*A(2)*L/2]; 

%% part d
Kr = K(2:3,2:3);
Fr = F(2:3);
Q = [0; Kr\Fr]; %in

%% part e
sigma = E/L*[Q(2)-Q(1); Q(3)-Q(2)]; %psi

%% part f
R = [K(1,:)*Q-F(1); 0; 0]; %lb