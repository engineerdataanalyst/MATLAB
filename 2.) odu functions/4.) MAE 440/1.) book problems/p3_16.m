%% given
P = 15000; %lb
E = [30; 10]*1e6; %psi
A = [1; 1.25]; %in^2
L = [36; 36]; %in

%% stiffness matrix and load vector
EAL = E.*A./L;
K = [EAL(1)    0    -EAL(1)    0    0; ...
       0     EAL(2)    0    -EAL(2) 0; ...
    -EAL(1)    0     EAL(1)    0    0; ...
       0    -EAL(2)    0     EAL(2) 0; ...
       0       0       0       0    0]; %lb/in
F = [0; 0; 0; 0; P]; %lb

%% penalty
C = max(diag(K))*1e4;
[a3 a4] = deal(0);
[B1 B5a Ba] = deal(36, -15, 0);
[B2 B5b Bb] = deal(36, -27, 0);

Kp = K;
Kp(3,3) = Kp(3,3)+C;
Kp(4,4) = Kp(4,4)+C;

Kp(1,1) = Kp(1,1)+C*B1^2;
Kp(1,5) = Kp(1,5)+C*B1*B5a;
Kp(5,1) = Kp(5,1)+C*B5a*B1;
Kp(5,5) = Kp(5,5)+C*B5a^2;

Kp(2,2) = Kp(2,2)+C*B2^2;
Kp(2,5) = Kp(2,5)+C*B2*B5b;
Kp(5,2) = Kp(5,2)+C*B5b*B2;
Kp(5,5) = Kp(5,5)+C*B5b^2;

Fp = F+C*[B1*Ba; B2*Bb; a3; a4; B5a*Ba+B5b*Bb];

%% solution
Q = Kp\Fp;
R = K*Q-F;
sigma = E./L.*[Q(3)-Q(1); Q(4)-Q(2)];