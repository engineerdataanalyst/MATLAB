%% given
% ---------------
w = 500; %lb/in
L = 2; %in
xp = 2; %in
yp = 1; %in
% ---------------
xy = [3 0; ...
      3 2; ...
      0 2; ...
      0 0]; %in
% ---------------
F = [w*L/2 0; ...
     w*L/2 0; ...
     0     0; ...
     0     0];
% ---------------
bound = [nan 0; ...
         0   nan; ...
         0   0; ...
         0   0];
% ---------------
connect = [1 2 4; ...
           3 4 2];
% ---------------
E = 30e6; %psi
t = 0.5; %in
nu = 0.25;
% ---------------.

%% finite element process
[tbl Ae Be De Ke K] = Cst(xy, F, bound, connect, E, t, nu);

%% displacement and stress at point P
[xi yi] = deal(xy(1,1), xy(1,2));
[xj yj] = deal(xy(2,1), xy(2,2));
[xk yk] = deal(xy(4,1), xy(4,2));

N = [1 1 1; xi xj xk; yi yj yk]^-1*[1; xp; yp];
[Ni Nj Nk] = deal(N(1), N(2), N(3));

Q = reshape(tbl.n.Q.', [8 1]);
up = [Ni 0 Nj 0 Nk 0; 0 Ni 0 Nj 0 Nk]*Q([1:4 7:8]);
stressp = De{1}*Be{1}*Q([1:4 7:8]);