%% beam
u = symunit;
P = sym('P');
L = sym('L');
b = beam('simply supported');

%% elastic curve
old_assum = assumptions;
clearassum;

[y dy m v w r] = b.elastic_curve;
addvar(y);

%% shear and moment diagrams
beam.shear_moment(m, v, [0 1], [P L], 1);
subplot(2,1,1);
axis([0 1 -0.65 0.65]);
subplot(2,1,2);
axis([0 1 0 0.28]);

%% section properties
D = sym('D');
R(D) = D/2;

I = pi*R^4/4;
A = pi*R^2;

%% loads at point A
assume(L > 0 & in(L, 'real'));
F = sym('F');
M_A(P,L) = m(L/2);
V_A(P) = v(0);
F_A(F) = -F;

%% stresses at point A
clear sigma_A;
sigma_A.axial(F,D) = F_A(F)/A(D);

y_A = -R;
sigma_A.bend(P,D) = -M_A(P,L)*y_A(D)/I(D);

tau_A = sym(0);

%% mohr stresses at point A
sigmax(F,P,D) = sigma_A.axial(F,D)+sigma_A.bend(P,D);
sigmay = sym(0);
tauxy = tau_A;

assume(formula(sigmax/2 ~= 0));
assumeAlso(formula(sigmax/2 >= 0));
assumeAlso(~formula(sigmax/2 < 0));

[sigmaxp sigmayp tauxyp thetap] = beam.principal(sigmax, sigmay, tauxy);
[sigmaxs sigmays tauxys thetas] = beam.max_shear(sigmax, sigmay, tauxy);

setassum(old_assum, 'clear');
clear old_assum;