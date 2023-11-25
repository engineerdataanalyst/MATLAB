%% given
P = 60e3; %N
E = 20*10^3; %N/mm^2
A = 250; %mm^2
L = 150; %mm

%% stiffness matrix and force vector
K = E*A/L*[1 -1   0; ...
          -1 1+1 -1; ...
           0 -1   1];
F = [0; P; 0];

%% nodal displacements 
Kr = K(2,2);
Fr = F(2)-K(2,3)*1.2;
Q = [0; Fr/Kr; 1.2]; %mm

%% part e
sigma = E/L*[Q(2)-Q(1); Q(3)-Q(2)]; %N/mm^2

%% part f
R = [K(1,:)*Q-F(1); 0; K(3,:)*Q-F(3)]; %N/mm^2