%% given
P = 300; %kN
E = 200; %kN/mm^2
A = [250; 250; 400]; %mm^2
L = [150; 150; 300]; %mm

%% stiffness matrix and force vector
K = E*[A(1)/L(1)  -A(1)/L(1)          0               0; ...
      -A(1)/L(1) 2*A(1)/L(1)     -A(2)/L(2)           0; ...
           0      -A(2)/L(2) A(2)/L(2)+A(3)/L(3) -A(3)/L(3); ...
           0           0         -A(3)/L(3)       A(3)/L(3)];
F = [0; P; 0; 0];

%% nodal displacements 
Kr = K(2:3,2:3);
Fr = F(2:3);
Q = [0; Kr\Fr; 0]; %mm

%% stresses
sigma = E./L.*[Q(2)-Q(1); Q(3)-Q(2); Q(4)-Q(3)]; %kN/mm^2

%% reactions
R = [K(1,:)*Q-F(1); 0; 0; K(4,:)*Q-F(4)]; %kN/mm^2