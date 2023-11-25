%% given
P = 200e3; %N
E = [70; 200]*10^3; %N/mm^2
A = [2400; 600]; %mm^2
L = [300; 400]; %mm

%% part a
EAL = E.*A./L;
K = [EAL(1)   -EAL(1)        0; ...
    -EAL(1) EAL(1)+EAL(2) -EAL(2); ...
       0      -EAL(2)      EAL(2)];
F = [0; P; 0];

Kr = K(2,2);
Fr = F(2);
Q = [0; Fr/Kr; 0]; %mm

%% part b
sigma = E./L.*[Q(2)-Q(1); Q(3)-Q(2)]; %N/mm^2

%% part c
R = [K(1,:)*Q-F(1); 0; K(3,:)*Q-F(3)]; %N/mm^2