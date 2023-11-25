%% filename string
filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\hw3\hw3.xlsx'];

%% part 1

% given
MC = 10; %kmol
MH = 22; %kmol
Tr = 500; %K
Tp = (600:100:2200)'; %K
Hrp = -6312300; %kJ/kmol
Mfuel = 142; %kg/kmol
Mair = 28.97; %kg/kmol

% calculations
Ycc = MC+MH/4;
dh = @(i,Tp) h(i,Tp)-h(i,Tr);
[num den] = deal(Tp);

for k = 1:length(Tp)
  num(k) = -Hrp-MC*dh(2,Tp(k))-MH/2*dh(3,Tp(k))+Ycc*dh(4,Tp(k));
  den(k) = dh(4,Tp(k))+3.76*dh(5,Tp(k));
end
Y = num./den;
f = Mfuel./(4.76*Y*Mair);

% data
tbl = table(Tp, f);
writetable(tbl, filename, 'Sheet', 'part 1');

%% part 2

% given
MC = 8; %kmol
MH = 18; %kmol
Tr = 650; %K
Hrp_fuel = -5089100; %kJ/kmol
Hrp_co = 282800; %kJ/kmol

% calculations
Ycc = MC+MH/4;
Ymin = Ycc-MC/2;
Y_Ycc = [Ymin/Ycc 0.8:0.1:2.0]';
Y = Ycc*Y_Ycc;
dh = @(i,Tp) h(i,Tp)-h(i,Tr);

n = length(Y);
N = zeros(n,5);
[N(Y<Ycc,1) N(Y>=Ycc,1)] = deal(2*(Ycc-Y(Y<Ycc)), 0); 
[N(Y<Ycc,2) N(Y>=Ycc,2)] = deal(2*(Y(Y<Ycc)-Ymin), MC);
N(:,3) = MH/2;
[N(Y<Ycc,4) N(Y>=Ycc,4)] = deal(0, Y(Y>=Ycc)-Ycc);
N(:,5) = 3.76*Y;

Tp = zeros(n,1);
F = @(k,Tp) Hrp_fuel+N(k,1)*(Hrp_co+dh(1,Tp))+...
                     N(k,2)*dh(2,Tp)+...
                     N(k,3)*dh(3,Tp)+...
                     N(k,4)*dh(4,Tp)+...
                     N(k,5)*dh(5,Tp);
for k = 1:n
  Tp(k) = fzero(@(Tp)F(k,Tp), 2000);
end

% data
tbl = table(Y_Ycc, Tp);
writetable(tbl, filename, 'Sheet', 'part 2');