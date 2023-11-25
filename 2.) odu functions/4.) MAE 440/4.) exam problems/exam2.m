%% problem 1
K = [2 -1 0 0; -1 5 -1 0; 0 -1 4 -1; 0 0 -1 2];
F = [2; 6; 6; 3];

KBB = [2 0; 0 2];
KBI = [-1 0; 0 -1];
KIB = [-1 0; 0 -1];
KII = [5 -1; -1 4];

qB = [1; 4];
fB = [2; 3];
fI = [6; 6];

qI = KII^-1*(fI-KIB*qB);
RB = KBB*qB+KBI*qI-fB;

q = [qB(1); qI; qB(2)];
R = [RB(1); zeros(2,1); RB(2)];

%% problem 2
K = [2 -1 0 0; -1 5 -1 0; 0 -1 4 -1; 0 0 -1 2];
F = [-1; 3; 3; 6];

C = max(diag(K))*1e4;
a1 = 0;
[B2 B4 B] = deal(-2, 1, 2);

Kp = K;
Kp(1,1) = Kp(1,1)+C;

Kp(2,2) = Kp(2,2)+C*B2^2;
Kp(2,4) = Kp(2,4)+C*B2*B4;
Kp(4,2) = Kp(4,2)+C*B4*B2;
Kp(4,4) = Kp(4,4)+C*B4^2;

Fp = F;
Fp(1) = Fp(1)+C*a1;
Fp(2) = Fp(2)+C*B2*B;
Fp(4) = Fp(4)+C*B4*B;

q = Kp^-1*Fp;
R = K*q-F;