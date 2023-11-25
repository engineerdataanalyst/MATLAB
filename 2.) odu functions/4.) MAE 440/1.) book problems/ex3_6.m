%% given
P = 30e3; %N
A = [1200; 900]; %mm^2;
E = [200; 70]*1e3; %N/mm^2
L = [4.5; 3]*1e3; %mm

%% stiffness matrix and load vector
EAL = E.*A./L;
K = [EAL(1)    0    -EAL(1)    0    0; ...
       0     EAL(2)    0    -EAL(2) 0; ...
    -EAL(1)    0     EAL(1)    0    0; ...
       0    -EAL(2)    0     EAL(2) 0; ...
       0       0       0       0    0];
F = [0; 0; 0; 0; 30e3]; %N
     
%% penalty
C = max(diag(K))*1e4;
[a3 a4] = deal(0);
[B1 B2] = deal(1);
[B5a B5b] = deal(-1/3, -5/6);
[Ba Bb] = deal(0);

Kp = K;
Kp(1,1) = Kp(1,1)+C*B1^2;
Kp(1,5) = Kp(1,5)+C*B1*B5a;
Kp(5,1) = Kp(5,1)+C*B5a*B1;
Kp(5,5) = Kp(5,5)+C*B5a^2;

Kp(2,2) = Kp(2,2)+C*B2^2;
Kp(2,5) = Kp(2,5)+C*B2*B5b;
Kp(5,2) = Kp(5,2)+C*B5b*B2;
Kp(5,5) = Kp(5,5)+C*B5b^2;

Kp(3,3) = Kp(3,3)+C;
Kp(4,4) = Kp(4,4)+C;

Fp = F+C*[B1*Ba; B2*Ba; a3; a4; B5a*Ba+B5b*Bb];

%% solution
Q = Kp\Fp;
R = K*Q-F;
sigma = E./L.*[Q(1)-Q(3); Q(2)-Q(4)];