%% given
t = 10; %mm
E = 70000; %N/mm^2
nu = 0.3;

x = [30; 0; 0]; %mm
y = [20; 20; 0]; %mm
[P2x P2y] = deal(50, -100); %N

%% element area
A = 1/2*det([1 x(1) y(1); ...
             1 x(2) y(2); ...
             1 x(3) y(3)]);

%% stiffness matrix
% ------------------
y23 = y(2)-y(3);
y31 = y(3)-y(1);
y12 = y(1)-y(2);
x32 = x(3)-x(2);
x13 = x(1)-x(3);
x21 = x(2)-x(1);
% ------------------
B = 1/(2*A)*[y23 0   y31 0   y12 0; ...
             0   x32 0   x13 0   x21; ...
             x32 y23 x13 y31 x21 y12];
% ------------------
D = E/(1-nu^2)*[1  nu 0; ...
                nu 1  0; ...
                0  0  (1-nu)/2];
% ------------------
K = t*abs(A)*B.'*D*B;

%% load vector
F = [P2x; P2y; 0; 0; 0; 0];

%% displacement field
b = 3:6;
i = 1:2;
Kr = K(i,i);
Fr = F(i);

Q = [Kr^-1*Fr; 0; 0; 0; 0];
R = [0; 0; K(b,:)*Q-F(b)];

%% stress
stress = D*B*Q;