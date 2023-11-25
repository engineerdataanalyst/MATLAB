% Given
Ma = 0.84;
pa = 54.05; %kPa
ta = 255.7; %K

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

% Flight Parameters
tint = 1400; %K
OPR = 24;
PRC_LP = 2;
PRC_HP = 12;

B = (0:0.25:4.75)';
nB = length(B);

% Subsonic Diffuser (Inlet)
Va = Ma*sqrt(ga*Ra*10^3*ta);
po1 = pa*(1+etaD*(ga-1)/2*Ma^2)^(ga/(ga-1));
to1 = ta*(1+(ga-1)/2*Ma^2);

% Low Pressure Compressor
po2 = po1*PRC_LP;
to2 = to1*(1+(PRC_LP^((ga-1)/ga)-1)/etaC);
wLPC = cpoa*(to1-to2)*(B+1);

% High Pressure Compressor
po3 = po2*PRC_HP;
to3 = to2*(1+(PRC_HP^((ga-1)/ga)-1)/etaC);
wHPC = cpoa*(to2-to3);

% Combustion Chamber
po4 = (1-dpob)*po3;
to4 = tint;

dh = @(i) h(i,to4)-h(i,to3);
Y = (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4))/(dh(4)+3.76*dh(5));
f = Mfuel/(4.76*Y*Mair*etab);

% High Pressure Turbine
to5 = to4+wHPC/(etam*(1+f)*cpog);
po5 = po4*(1-(1-to5/to4)/etat)^(gg/(gg-1));

% Low Pressure Turbine
to6 = to5+wLPC/(etam*(1+f)*cpog);
po6 = po5*(1-(1-to6/to5)/etat).^(gg/(gg-1));

% Hot Nozzle
pshpo6 = (1-1/etaN*(1-2/(gg+1)))^(gg/(gg-1));
[Meh peh teh reh] = deal(B);
for k = 1:nB
  if pa/po6(k) <= pshpo6
    Meh(k) = 1;
    peh(k) = po6(k)*pshpo6;
    teh(k) = to6(k)*2/(gg+1);
    reh(k) = peh(k)/(Rg*teh(k));
  else
    peh(k) = pa;
    teh(k) = to6(k)*(1-etaN*(1-(peh(k)/po6(k))^((gg-1)/gg)));
    reh(k) = peh(k)/(Rg*teh(k));
    Meh(k) = sqrt((to6(k)/teh(k)-1)*2/(gg-1));
  end
end
Veh = Meh.*sqrt(gg*Rg*10^3*teh);

% Cold Nozzle
pscpo2 = (1-1/etaN*(1-2/(ga+1)))^(ga/(ga-1));
if pa/po2 <= pscpo2
  Mec = 1;
  pec = po2*pscpo2;
  tec = to2*2/(ga+1);
  rec = pec/(Ra*tec);
else
  pec = pa;
  tec = to6*(1-etaN*(1-(pec/po2)^((ga-1)/ga)));
  rec = pec/(Ra*tec);
  Mec = sqrt((to2/tec-1)*2/(ga-1));
end
Vec = Mec*sqrt(ga*Ra*10^3*tec);

% Performance Chart
Fsh = ((1+f)*Veh-Va+(peh-pa)*10^3*(1+f)./(reh.*Veh))./(B+1);
Fsc = B*(Vec-Va+(pec-pa)*10^3/(rec*Vec))./(B+1);
Fs = Fsh+Fsc;
tsfc = f./((B+1).*Fs)*3600;

filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\hw6\hw6.xlsx'];
data = [B Fs];
xlswrite(filename, data, 'Fs vs B', 'A2');
data = [B tsfc];
xlswrite(filename, data, 'tsfc vs B', 'A2');