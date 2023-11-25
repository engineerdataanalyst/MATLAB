%% given
P = 385; %kN
E = [70; 105]; %kN/mm^2
A = [1800; 1800]; %mm^2
L = [200; 200]; %mm

%% stiffness matrix and load vector
EAL = E.*A./L;
K = [EAL(1) -EAL(1)   0       0    0; ...
    -EAL(1)  EAL(1)   0       0    0; ...
       0       0    EAL(2) -EAL(2) 0; ...
       0       0   -EAL(2)  EAL(2) 0; ...
       0       0      0       0    0]; %kN/mm
F = [0; 0; 0; 0; P]; %kN

%% penalty
C = max(diag(K))*1e4; %kN/mm
[a2 a4] = deal(0);
[B1 B5a Ba] = deal(1, -1, 0);
[B3 B5b Bb] = deal(1, -1, 0);

Kp = K;
Kp(2,2) = Kp(2,2)+C;
Kp(4,4) = Kp(4,4)+C;

Kp(1,1) = Kp(1,1)+C*B1^2;
Kp(1,5) = Kp(1,5)+C*B1*B5a;
Kp(5,1) = Kp(5,1)+C*B5a*B1;
Kp(5,5) = Kp(5,5)+C*B5a^2;

Kp(3,3) = Kp(3,3)+C*B3^2;
Kp(3,5) = Kp(3,5)+C*B3*B5b;
Kp(5,3) = Kp(5,3)+C*B5b*B3;
Kp(5,5) = Kp(5,5)+C*B5b^2;

Fp = F+C*[B1*Ba; a2; B3*Bb; a4; B5a*Ba+B5b*Bb];

%% solution
Q = Kp\Fp; %mm
R = K*Q-F; %kN
sigma = E./L.*[Q(2)-Q(1); Q(4)-Q(3)]*1e3; %MPa