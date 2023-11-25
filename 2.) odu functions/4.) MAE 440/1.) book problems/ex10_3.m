%% given
k = 360; %W/(m-C)
t = 0.1e-2; %m
w = 1; %m
T1 = 235; %C
Tinf = 20; %C
h = 9; %W/(m^2-C)
L = 10e-2/3; %m

%% fin area and perimeter
P = 2*(w+t);
A = w*t;

%% stiffness matricies
% ------------------------
Ke = cell(3,1);
kL = k/L;
PhLA = P*h*L/(6*A);
% ------------------------
Ke{1} = [kL+2*PhLA -kL+PhLA   0 0; ...
        -kL+PhLA    kL+2*PhLA 0 0; ...
            0           0     0 0; ...
            0           0     0 0];
% ------------------------
Ke{2} = [0     0          0      0; ...
         0  kL+2*PhLA -kL+PhLA   0; ...
         0 -kL+PhLA    kL+2*PhLA 0; ...
         0     0          0      0];
% ------------------------
Ke{3} = [0  0      0         0; ...
         0  0      0         0; ...
         0  0  kL+2*PhLA -kL+PhLA; ...
         0  0 -kL+PhLA    kL+2*PhLA];
% ------------------------
K = Ke{1}+Ke{2}+Ke{3};
% ------------------------

%% force vector
% ------------------------
Fe = cell(3,1);
PhTinfLA = P*h*Tinf*L/(2*A);
% ------------------------
Fe{1} = PhTinfLA*[1; 1; 0; 0];
Fe{2} = PhTinfLA*[0; 1; 1; 0];
Fe{3} = PhTinfLA*[0; 0; 1; 1];
% ------------------------
F = Fe{1}+Fe{2}+Fe{3};
% ------------------------

%% solution
Kr = K(2:4,2:4);
Fr = F(2:4)-K(2:4,1)*T1;
T = [T1; Kr^-1*Fr];
q = [K(1,:)*T-F(1); 0; 0; 0];