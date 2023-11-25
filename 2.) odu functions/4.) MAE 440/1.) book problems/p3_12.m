%% given
E = 200; %kN/mm^2
A = [250; 250; 400; 400]; %mm^2
L = [150; 150; 200; 200]; %mm

%% stiffness matrix and force vector
AL = A./L;
K = E*[AL(1)  -AL(1)      0          0      0; ...
      -AL(1) 2*AL(1)   -AL(2)        0      0; ...
         0    -AL(2) AL(2)+AL(3)  -AL(3)    0; ...
         0       0     -AL(3)    2*AL(3) -AL(4); ...
         0       0        0       -AL(4)  AL(4)]; %kN/mm
F = [0; 300; 0; 600; 0]; %kN

%% penalty
C = max(diag(K))*1e4; %kN/mm
[a1 a5] = deal(0, 3.5); %mm

Kp = K;
Kp(1,1) = Kp(1,1)+C;
Kp(5,5) = Kp(5,5)+C;

Fp = F;
Fp(1) = Fp(1)+C*a1;
Fp(5) = Fp(5)+C*a5;

Qp = Kp\Fp;
Rp = K*Qp-F;
sigmap = E./L.*[Qp(2)-Qp(1); Qp(3)-Qp(2); Qp(4)-Qp(3); Qp(5)-Qp(4)];

%% elminiation
Ke = K(2:4,2:4);
Fe = F(2:4)-K(2:4,[1 5])*[0; 3.5];

Qe = [0; Ke\Fe; 3.5];
Re = [K(1,:)*Qe-F(1); 0; 0; 0; K(5,:)*Qe-F(5)];
sigmae = E./L.*[Qe(2)-Qe(1); Qe(3)-Qe(2); Qe(4)-Qe(3); Qe(5)-Qe(4)];