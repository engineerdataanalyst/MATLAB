%% part a
L = 4; %m
P = 2; %N
E = 50; %N/m^2
t = 0.2; %m

syms x a1 a2;
h(x) = 1/4*(4-x);
A = (1+2*h)*t;

a0 = 0;
f(x) = x^2;
u(x) = a0+a1*x+a2*x^2;
Pi = int((E/2*diff(u)^2-f*u)*A, 0, L)-P*u(L);

a = sym.zeros(3,1);
[a(2) a(3)] = solve(diff(Pi,a1) == 0, diff(Pi,a2) == 0, [a1 a2]);

%% part b
% given
E = [50; 50]; %N/m^2
A = [2.5; 1.5]*0.2; %m^2
L = [2; 2]; %m

% stiffness matrix and load vector
EAL = E.*A./L;
K = [EAL(1)   -EAL(1)        0; ...
    -EAL(1) EAL(1)+EAL(2) -EAL(2); ...
       0      -EAL(2)      EAL(2)];
F = A(1)*L(1)/2*[1; 1; 0]+3^2*A(2)*L(2)/2*[0; 1; 1]+[0; 0; 2];

% penalty
C = max(diag(K))*1e4;
a1 = 0;

Kp = K;
Kp(1,1) = Kp(1,1)+C;

Fp = F+[C*a1; 0; 0];

Q = Kp\Fp;
R = K*Q-F;
sigma = E./L.*[Q(2)-Q(1); Q(3)-Q(2)];
