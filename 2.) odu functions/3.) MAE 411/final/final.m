%% Part 1

% Given
R = 8.31451; %kJ/kmol/K
V1 = 0.0005; %m^3
p1 = 100; %kPa
t1 = 300; %K
rv = 9;

M_fuel = 114; %kg/kmol
MC = 8; %kmol
MH = 18; %kmol

Ycc = MC+MH/4;
Ymin = Ycc-MC/2;
Y = (0.7:0.1:1.4)'*Ycc;
nY = length(Y);
filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\final\final.xlsx']; 

% Process 1-2
y_fuel = 1./(1+4.76*Y);
y_air = 4.76*Y./(1+4.76*Y);

n_tot = p1*V1/(R*t1);
n_fuel = y_fuel*n_tot;
n_air = y_air*n_tot;
m_fuel = n_fuel*M_fuel;

[a_air b_air] = deal(27.5, 0.0057);
[a_fuel b_fuel] = deal(38.4, 0.429);
phi = @(a,b,t1,t2) (a-R)*log(t2/t1)+b*(t2-t1);

t2 = Y;
for k = 1:nY
  F = @(t2) y_air(k)*phi(a_air,b_air,t1,t2)+...
            y_fuel(k)*phi(a_fuel,b_fuel,t1,t2)+...
            R*log(1/rv);
  t2(k) = fzero(F, 900);
end
w12 = -n_fuel.*((a_fuel-R)*(t2-t1)+b_fuel*(t2.^2-t1^2)/2)...
      -n_air.*((a_air-R)*(t2-t1)+b_air*(t2.^2-t1^2)/2);

% Process 2-3
Urp_fuel = -5097780; %kJ/kmol
Urp_CO_CO2 = 281400; %kJ/kmol

[N_CO N_CO2 N_H2O N_O2 N_N2] = deal(Y);
N_CO(Y < Ycc) = 2*(Ycc-Y(Y < Ycc));
N_CO2(Y < Ycc) = 2*(Y(Y < Ycc)-Ymin);
N_H2O(Y < Ycc) = MH/2;
N_O2(Y < Ycc) = 0;
N_N2(Y < Ycc) = 3.76*Y(Y < Ycc);

N_CO(Y == Ycc) = 0;
N_CO2(Y == Ycc) = MC;
N_H2O(Y == Ycc) = MH/2;
N_O2(Y == Ycc) = 0;
N_N2(Y == Ycc) = 3.76*Ycc;

N_CO(Y > Ycc) = 0;
N_CO2(Y > Ycc) = MC;
N_H2O(Y > Ycc) = MH/2;
N_O2(Y > Ycc) = Y(Y > Ycc)-Ycc;
N_N2(Y > Ycc) = 3.76*Y(Y > Ycc);
sumN = N_CO+N_CO2+N_H2O+N_O2+N_N2;

t3 = Y;
for k = 1:nY
  du = @(i,t3) h(i,t3)-h(i,t2(k))-R*(t3-t2(k));  
  F = @(t3) Urp_fuel+N_CO(k)*(Urp_CO_CO2+du(1,t3))...
                    +N_CO2(k)*du(2,t3)...
                    +N_H2O(k)*du(3,t3)...
                    +N_O2(k)*du(4,t3)...
                    +N_N2(k)*du(5,t3);
  t3(k) = fzero(F, 3000);
end
n3n2 = sumN./(1+4.76*Y);

% Process 3-4
n2 = n_tot;
n3 = n2*n3n2;

y_CO = N_CO./sumN;
y_CO2 = N_CO2./sumN;
y_H2O = N_H2O./sumN;
y_O2 = N_O2./sumN;
y_N2 = N_N2./sumN;

n_CO = y_CO.*n3;
n_CO2 = y_CO2.*n3;
n_H2O = y_H2O.*n3;
n_O2 = y_O2.*n3;
n_N2 = y_N2.*n3;

[t4 w34] = deal(Y);
for k = 1:nY
  dPhi = @(i,t4) Phi(i,t4)-Phi(i,t3(k));
  dh = @(i,t4) h(i,t4)-h(i,t3(k))-R*(t4-t3(k));
  F = @(t4) R*log(rv*t3(k)/t4)+y_CO(k)*dPhi(1,t4)...
                              +y_CO2(k)*dPhi(2,t4)...
                              +y_H2O(k)*dPhi(3,t4)...
                              +y_O2(k)*dPhi(4,t4)...
                              +y_N2(k)*dPhi(5,t4);
  t4(k) = fzero(F, 1500);
  w34(k) = -n_CO(k)*dh(1,t4(k))...
           -n_CO2(k)*dh(2,t4(k))...
           -n_H2O(k)*dh(3,t4(k))...
           -n_O2(k)*dh(4,t4(k))...
           -n_N2(k)*dh(5,t4(k));
end

% Results
HV = 5097780; %kJ/kmol fuel
pps = 25; %power strokes/sec

wnet = (w12+w34)*pps;
etath = wnet./(n_fuel*HV*pps); 
sfc = m_fuel*pps./wnet; 

data = [Y/Ycc wnet etath sfc];
xlswrite(filename, data, 'part 1', 'A2');

%% Part 2

% Given
R = 8.31451; %kJ/kmol/K
V1 = 0.0005; %m^3
p1 = 100; %kPa
t1 = 300; %K

rv = (6.0:0.5:12.0)';
nrv = length(rv);

M_fuel = 114; %kg/kmol
MC = 8; %kmol
MH = 18; %kmol

Ycc = MC+MH/4;
Y = Ycc;
filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\final\final.xlsx']; 

% Process 1-2
y_fuel = 1/(1+4.76*Y);
y_air = 4.76*Y/(1+4.76*Y);

n_tot = p1*V1/(R*t1);
n_fuel = y_fuel*n_tot;
n_air = y_air*n_tot;
m_fuel = n_fuel*M_fuel;

[a_air b_air] = deal(27.5, 0.0057);
[a_fuel b_fuel] = deal(38.4, 0.429);
phi = @(a,b,t1,t2) (a-R)*log(t2/t1)+b*(t2-t1);

t2 = rv;
for k = 1:nrv
  F = @(t2) y_air*phi(a_air,b_air,t1,t2)+...
            y_fuel*phi(a_fuel,b_fuel,t1,t2)+...
            R*log(1/rv(k));
  t2(k) = fzero(F, 900);
end
w12 = -n_fuel*((a_fuel-R)*(t2-t1)+b_fuel*(t2.^2-t1^2)/2)...
      -n_air*((a_air-R)*(t2-t1)+b_air*(t2.^2-t1^2)/2);

% Process 2-3
Urp_fuel = -5097780; %kJ/kmol
Urp_CO_CO2 = 281400; %kJ/kmol

N_CO = 0;
N_CO2 = MC;
N_H2O = MH/2;
N_O2 = 0;
N_N2 = 3.76*Ycc;
sumN = N_CO+N_CO2+N_H2O+N_O2+N_N2;

t3 = rv;
for k = 1:nrv
  du = @(i,t3) h(i,t3)-h(i,t2(k))-R*(t3-t2(k));  
  F = @(t3) Urp_fuel+N_CO*(Urp_CO_CO2+du(1,t3))...
                    +N_CO2*du(2,t3)...
                    +N_H2O*du(3,t3)...
                    +N_O2*du(4,t3)...
                    +N_N2*du(5,t3);
  t3(k) = fzero(F, 3000);
end
n3n2 = sumN/(1+4.76*Y);

% Process 3-4
n2 = n_tot;
n3 = n2*n3n2;

y_CO = N_CO/sumN;
y_CO2 = N_CO2/sumN;
y_H2O = N_H2O/sumN;
y_O2 = N_O2/sumN;
y_N2 = N_N2/sumN;

n_CO = y_CO*n3;
n_CO2 = y_CO2*n3;
n_H2O = y_H2O*n3;
n_O2 = y_O2*n3;
n_N2 = y_N2*n3;

[t4 w34] = deal(rv);
for k = 1:nrv
  dPhi = @(i,t4) Phi(i,t4)-Phi(i,t3(k));
  dh = @(i,t4) h(i,t4)-h(i,t3(k))-R*(t4-t3(k));
  F = @(t4) R*log(rv(k)*t3(k)/t4)+y_CO*dPhi(1,t4)...
                                 +y_CO2*dPhi(2,t4)...
                                 +y_H2O*dPhi(3,t4)...
                                 +y_O2*dPhi(4,t4)...
                                 +y_N2*dPhi(5,t4);
  t4(k) = fzero(F, 1500);
  w34(k) = -n_CO*dh(1,t4(k))...
           -n_CO2*dh(2,t4(k))...
           -n_H2O*dh(3,t4(k))...
           -n_O2*dh(4,t4(k))...
           -n_N2*dh(5,t4(k));
end

% Results
HV = 5097780; %kJ/kmol fuel
pps = 25; %power strokes/sec

wnet = (w12+w34)*pps;
etath = wnet/(n_fuel*HV*pps); 
sfc = m_fuel*pps./wnet;

data = [rv wnet etath sfc];
xlswrite(filename, data, 'part 2', 'A2');