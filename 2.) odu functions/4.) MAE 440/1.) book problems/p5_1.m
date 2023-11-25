%% given
% ---------------
F = [0    0; ...
    -3000 0; ...
     0    0; ...
     0    0]; %N
% ---------------
bound = [0   nan; ...
         nan nan; ...
         nan nan; ...
         0   nan];
% ---------------
connect = [1 2; ...
           2 3; ...
           3 4];
% ---------------
E = 200e3; %N/mm^2
I = [1.25e5; 1.25e5; 4e4]; %mm^4
L = [150; 75; 125]; %mm
% ---------------.

%% solution
[tbl Ke K] = Beam(F, bound, connect, E, I, L);