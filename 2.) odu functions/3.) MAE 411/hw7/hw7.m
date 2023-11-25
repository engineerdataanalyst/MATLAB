%% Part 1

% Given
[Ra Rg] = deal(0.287); %kJ/kg/K
[ga gg] = deal(1.4, 1.3333);
cpoa = ga*Ra/(ga-1); %kJ/kg/K
cpog = gg*Rg/(gg-1); %kJ/kg/K

[MC MH] = deal(14.4, 24.9); %kmol
Ycc = MC+MH/4; %kmol
Mfuel = 197.7; %kg/kmol
Mair = 28.97; %kg/kmol
Hrp = -8561991.6; %kJ/kmol

[etaD etaC etaN] = deal(0.93, 0.87, 0.95);
[etab etam etat] = deal(0.98, 0.99, 0.90);
dpob = 0.04;
PRC = 3;

% flight parameters
Ma = 0.84;
pa = 54.05; %kPa
ta = 255.7; %K

tint = 1200; %K
tAB = (1200:100:2000)'; %K
nAB = length(tAB);

% Subsonic Diffuser (Inlet)
Va = Ma*sqrt(ga*Ra*10^3*ta);
po1 = pa*(1+etaD*(ga-1)/2*Ma^2)^(ga/(ga-1));
to1 = ta*(1+(ga-1)/2*Ma^2);

% Low Pressure Compressor
po2 = po1*PRC;
to2 = to1*(1+(PRC^((ga-1)/ga)-1)/etaC);
wLPC = cpoa*(to1-to2);

% High Pressure Compressor
po3 = po2*PRC;
to3 = to2*(1+(PRC^((ga-1)/ga)-1)/etaC);
wHPC = cpoa*(to2-to3);

% Combustion Chamber
po4 = (1-dpob)*po3;
to4 = tint;
dh = @(i) h(i,to4)-h(i,to3);
X = (dh(4)+3.76*dh(5))./...
    (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4));
fcc = X*Mfuel/(4.76*Mair*etab);

% High Pressure Turbine
to5 = to4+wHPC/(etam*(1+fcc)*cpog);
po5 = po4*(1-(1-to5/to4)/etat)^(gg/(gg-1));

% Low Pressure Turbine
to6 = to5+wLPC/(etam*(1+fcc)*cpog);
po6 = po5*(1-(1-to6/to5)/etat)^(gg/(gg-1));

% Converging Nozzle (No After Burner)
pspo6 = (1-1/etaN*(1-2/(gg+1)))^(gg/(gg-1));
if pa/po6 <= pspo6
  Me_noAB = 1;
  pe_noAB = po6*pspo6;
  te_noAB = to6*2/(gg+1);
  re_noAB = pe_noAB/(Rg*te_noAB);
else
  pe_noAB = pa;
  te_noAB = to6*(1-etaN*(1-(pe_noAB/po6)^((gg-1)/gg)));
  re_noAB = pe_noAB/(Rg*te_noAB);
  Me_noAB = sqrt((to6/te_noAB-1)*2/(gg-1));
end
Ve_noAB = Me_noAB*sqrt(gg*Rg*10^3*te_noAB);

% After Burner
po7 = (1-dpob)*po6; 
[to7 Z] = deal(tAB);
for k = 1:nAB
  dh = @(i) h(i,to7(k))-h(i,to6);
  Z(k) = (3.76*dh(5)+dh(4)+X*(MC*dh(2)+MH/2*dh(3)-Ycc*dh(4)))./...
         (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4));
end
fAB = Z*Mfuel/(4.76*Mair*etab);
fo = fcc+fAB;

% Converging Nozzle (After Burner)
pspo7 = pspo6;
[Me_AB pe_AB te_AB re_AB] = deal(tAB);
for k = 1:nAB
  if pa/po7 <= pspo7
    Me_AB(k) = 1;
    pe_AB(k) = po7*pspo7;
    te_AB(k) = to7(k)*2/(gg+1);
    re_AB(k) = pe_AB(k)/(Rg*te_AB(k));
  else
    pe_AB(k) = pa;
    te_AB(k) = to7(k)*(1-etaN*(1-(pe_AB(k)/po7)^((gg-1)/gg)));
    re_AB(k) = pe_AB(k)/(Rg*te_AB(k));
    Me_AB(k) = sqrt((to7(k)/te_AB(k)-1)*2/(gg-1));
  end  
end
Ve_AB = Me_AB.*sqrt(gg*Rg*10^3*te_AB);

% Performance Chart
Fs_noAB = (1+fcc)*Ve_noAB-Va+...
          (pe_noAB-pa)*10^3*(1+fcc)/(re_noAB*Ve_noAB);
tsfc_noAB = fcc./Fs_noAB*3600;

Fs_AB = (1+fo).*Ve_AB-Va+...
        (pe_AB-pa)*10^3.*(1+fo)./(re_AB.*Ve_AB);
tsfc_AB = fo./Fs_AB*3600;

filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\hw7\hw7.xlsx'];
data = [tAB Fs_AB Fs_AB/Fs_noAB tsfc_AB tsfc_AB/tsfc_noAB];
xlswrite(filename, data, 'part 1', 'A2');
data = [Fs_noAB; tsfc_noAB];
xlswrite(filename, data, 'part 1', 'B12');

%% Part 2

% Given
[Ra Rg] = deal(0.287); %kJ/kg/K
[ga gg] = deal(1.4, 1.3333);
cpoa = ga*Ra/(ga-1); %kJ/kg/K
cpog = gg*Rg/(gg-1); %kJ/kg/K

[MC MH] = deal(14.4, 24.9); %kmol
Ycc = MC+MH/4; %kmol
Mfuel = 197.7; %kg/kmol
Mair = 28.97; %kg/kmol
Hrp = -8561991.6; %kJ/kmol

[etaD etaC etaN] = deal(0.93, 0.87, 0.95);
[etab etam etat] = deal(0.98, 0.99, 0.90);
dpob = 0.04;
PRC = 3;

% Flight Parameters
Va = (0:50:300)'; %m/sec
pa = 101.3; %kPa
ta = 288.2; %K

tint = 1200; %K
tAB = 2000; %K
nVa = length(Va);

% Subsonic Diffuser (Inlet)
Ma = Va/sqrt(ga*Ra*10^3*ta);
po1 = pa*(1+etaD*(ga-1)/2*Ma.^2).^(ga/(ga-1));
to1 = ta*(1+(ga-1)/2*Ma.^2);

% Low Pressure Compressor
po2 = po1*PRC;
to2 = to1*(1+(PRC^((ga-1)/ga)-1)/etaC);
wLPC = cpoa*(to1-to2);

% High Pressure Compressor
po3 = po2*PRC;
to3 = to2*(1+(PRC^((ga-1)/ga)-1)/etaC);
wHPC = cpoa*(to2-to3);

% Combustion Chamber
po4 = (1-dpob)*po3;
to4 = tint;
X = Va;
for k = 1:nVa
  dh = @(i) h(i,to4)-h(i,to3(k));
  X(k) = (dh(4)+3.76*dh(5))/...
         (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4));  
end
fcc = X*Mfuel/(4.76*Mair*etab);

% High Pressure Turbine
to5 = to4+wHPC./(etam*(1+fcc)*cpog);
po5 = po4.*(1-(1-to5/to4)/etat).^(gg/(gg-1));

% Low Pressure Turbine
to6 = to5+wLPC./(etam*(1+fcc)*cpog);
po6 = po5.*(1-(1-to6./to5)/etat).^(gg/(gg-1));

% Converging Nozzle (No After Burner)
pspo6 = (1-1/etaN*(1-2/(gg+1)))^(gg/(gg-1));
[Me_noAB pe_noAB te_noAB re_noAB] = deal(Va);
for k = 1:nVa
  if pa/po6(k) <= pspo6
    Me_noAB(k) = 1;
    pe_noAB(k) = po6(k)*pspo6;
    te_noAB(k) = to6(k)*2/(gg+1);
    re_noAB(k) = pe_noAB(k)/(Rg*te_noAB(k));
  else
    pe_noAB(k) = pa;
    te_noAB(k) = to6(k)*(1-etaN*(1-(pe_noAB(k)/po6)^((gg-1)/gg)));
    re_noAB(k) = pe_noAB(k)/(Rg*te_noAB(k));
    Me_noAB(k) = sqrt((to6(k)/te_noAB(k)-1)*2/(gg-1));
  end
end
Ve_noAB = Me_noAB.*sqrt(gg*Rg*10^3*te_noAB);

% After Burner
po7 = (1-dpob)*po6; 
to7 = tAB;
Z = Va;
for k = 1:nVa
  dh = @(i) h(i,to7)-h(i,to6(k));
  Z(k) = (3.76*dh(5)+dh(4)+X(k)*(MC*dh(2)+MH/2*dh(3)-Ycc*dh(4)))/...
         (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4));
end
fAB = Z*Mfuel/(4.76*Mair*etab);
fo = fcc+fAB;

% Converging Nozzle (After Burner)
pspo7 = pspo6;
[Me_AB pe_AB te_AB re_AB] = deal(Va);
for k = 1:length(po7)
  if pa/po7(k) <= pspo7
    Me_AB(k) = 1;
    pe_AB(k) = po7(k)*pspo7;
    te_AB(k) = to7*2/(gg+1);
    re_AB(k) = pe_AB(k)/(Rg*te_AB(k));
  else
    pe_AB(k) = pa;
    te_AB(k) = to7*(1-etaN*(1-(pe_AB(k)/po7)^((gg-1)/gg)));
    re_AB(k) = pe_AB(k)/(Rg*te_AB(k));
    Me_AB(k) = sqrt((to7/te_AB(k)-1)*2/(gg-1));
  end  
end
Ve_AB = Me_AB.*sqrt(gg*Rg*10^3*te_AB);

% Performance Chart
Fs_noAB = (1+fcc).*Ve_noAB-Va+...
          (pe_noAB-pa)*10^3.*(1+fcc)./(re_noAB.*Ve_noAB);
tsfc_noAB = fcc./Fs_noAB*3600;

Fs_AB = (1+fo).*Ve_AB-Va+...
        (pe_AB-pa)*10^3.*(1+fo)./(re_AB.*Ve_AB);
tsfc_AB = fo./Fs_AB*3600;

filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\hw7\hw7.xlsx'];
data = [Va Fs_AB Fs_noAB tsfc_AB tsfc_noAB];
xlswrite(filename, data, 'part 2', 'A2');