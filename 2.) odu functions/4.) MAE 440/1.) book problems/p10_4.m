%% given
d = 5/16*1/12; %ft
L = 5/2*1/12; %ft
T1 = 150; %F
Tinf = 80; %F
h = 6; %BTU/(hr-ft^2-F)
k = 24.8; %BTU/(hr-ft^2-F)

%% fin area and perimeter
P = pi*d;
A = pi/4*d^2;

%% stiffness matricies
% ------------------------
Ke = cell(2,1);
kL = k/L;
PhLA = P*h*L/(6*A);
% ------------------------
Ke{1} = [kL+2*PhLA -kL+PhLA   0; ...
        -kL+PhLA    kL+2*PhLA 0; ...
            0           0     0];
% ------------------------
Ke{2} = [0     0          0; ...
         0  kL+2*PhLA -kL+PhLA; ...
         0 -kL+PhLA    kL+2*PhLA];
% ------------------------
K = Ke{1}+Ke{2};
% ------------------------

%% force vector
% ------------------------
Fe = cell(2,1);
PhTinfLA = P*h*Tinf*L/(2*A);
% ------------------------
Fe{1} = PhTinfLA*[1; 1; 0];
Fe{2} = PhTinfLA*[0; 1; 1];
% ------------------------
F = Fe{1}+Fe{2};
% ------------------------

%% temperature distribution
Kr = K(2:3,2:3);
Fr = F(2:3)-K(2:3,1)*T1;
T = [T1; Kr^-1*Fr];
q = [K(1,:)*T-F(1); 0; 0];

%% heat loss
As = pi*d*L;
H = sum(h*As*([mean(T(1:2)) mean(T(2:3))]-Tinf));