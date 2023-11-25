%% given
% -------------------
w = -12e3; %N/m
l = 1; %m
% -------------------
F = [0      0; ...
     w*l/2  w*l^2/12; ...
     w*l/2 -w*l^2/12]; %N
% -------------------
bound = [0 0; ...
         0 nan; ...
         0 nan]; %[m rad]
% -------------------
connect = [1 2; ...
           2 3];
% -------------------
E = 200e9; %N/m^2
I = 4e6*1e-12; %m^2
L = 1; %m
% -------------------

%% finite element process
[tbl Ke K] = Beam(F, bound, connect, E, I, L);

%% displacement at midpoint of element 2
x = 0.5; %m
Q = reshape(tbl.n.Q.', [6 1]);
N1 = 1-3*x^2/L^2+2*x^3/L^3;
N2 = x-2*x^2/L+x^3/L^2;
N3 = 3*x^2/L^2-2*x^3/L^3;
N4 = -x^2/L+x^3/L^2;
um2 = [N1 N2 N3 N4]*Q(3:6);