%% Given
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

tint = 1400; %K
OPR = 24;
PRC_LP = 2;
PRC_HP = 12;

%% Subsonic Diffuser (Inlet)
Va = Ma*sqrt(ga*Ra*10^3*ta);
% poa = pa*(1+(ga-1)/2*Ma^2)^(ga/(ga-1));

po1 = pa*(1+etaD*(ga-1)/2*Ma^2)^(ga/(ga-1));
to1 = ta*(1+(ga-1)/2*Ma^2);

%% Devices
po6 = 2*pa;
B = 0;
k = 1;
while po6(k) > pa
  % Low Pressure Compressor
  po2(k) = po1*PRC_LP;
  to2(k) = to1*(1+(PRC_LP^((ga-1)/ga)-1)/etaC);
  wLPC(k) = cpoa*(to1-to2(k))*(B(k)+1);

  % High Pressure Compressor
  po3(k) = po2(k)*PRC_HP;
  to3(k) = to2(k)*(1+(PRC_HP^((ga-1)/ga)-1)/etaC);
  wHPC(k) = cpoa*(to2(k)-to3(k));

  % Combustion Chamber
  po4(k) = (1-dpob)*po3(k);
  to4(k) = tint;

  dh = @(i) h(i,to4(k))-h(i,to3(k));    
  num = -Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4);
  den = dh(4)+3.76*dh(5);    
  Y(k) = num/den;
  f(k) = Mfuel/(4.76*Y(k)*Mair*etab);

  % High Pressure Turbine
  to5(k) = to4(k)+wHPC(k)/(etam*(1+f(k))*cpog);
  po5(k) = po4(k)*(1-(1-to5(k)/to4(k))/etat)^(gg/(gg-1));

  % Low Pressure Turbine
  to6(k) = to5(k)+wLPC(k)/(etam*(1+f(k))*cpog);
  po6(k) = po5(k)*(1-(1-to6(k)/to5(k))/etat)^(gg/(gg-1));
  
  % Hot Nozzle
  pshpo6(k) = (1-1/etaN*(1-2/(gg+1)))^(gg/(gg-1));
  if pa/po6(k) <= pshpo6(k)
    Meh(k) = 1;
    peh(k) = po6(k)*pshpo6(k);
    teh(k) = to6(k)*2/(gg+1);
    reh(k) = peh(k)/(Rg*teh(k));
  else
    peh(k) = pa;
    teh(k) = to6(k)*(1-etaN*(1-(peh(k)/po6(k))^((gg-1)/gg)));
    reh(k) = peh(k)/(Rg*teh(k));
    Meh(k) = sqrt((to6(k)/teh(k)-1)*2/(gg-1));
  end
  Veh(k) = Meh(k)*sqrt(gg*Rg*10^3*teh(k));
  
  % Cold Nozzle
  pscpo2(k) = (1-1/etaN*(1-2/(ga+1)))^(ga/(ga-1));
  if pa/po2(k) <= pscpo2(k)
    Mec(k) = 1;
    pec(k) = po2(k)*pscpo2(k);
    tec(k) = to2(k)*2/(ga+1);
    rec(k) = pec(k)/(Ra*tec(k));
  else
    pec(k) = pa;
    tec(k) = to6(k)*(1-etaN*(1-(pec(k)/po2(k))^((ga-1)/ga)));
    rec(k) = pec(k)/(Ra*tec(k));
    Mec(k) = sqrt((to2(k)/tec(k)-1)*2/(ga-1));
  end
  Vec(k) = Mec(k)*sqrt(ga*Ra*10^3*tec(k));
  
  po6(k+1) = po6(k);
  if po6(k+1) > pa
    B(k+1) = B(k)+0.25;    
  end
  k = k+1;
end

%% Performance Chart
Fsh = ((1+f).*Veh-Va+(peh-pa)*10^3.*(1+f)./(reh.*Veh))./(B+1);
Fsc = B.*(Vec-Va+(pec-pa)*10^3./(rec.*Vec))./(B+1);
Fs = Fsh+Fsc; %N/kg/sec
tsfc = f./((B+1).*Fs)*3600; %kg/hour/N

% t = table(B(1:end-1)', Fs(1:end-1)');
% writetable(t, 'Fs vs B.csv');
% t = table(B(1:end-1)', tsfc(1:end-1)');
% writetable(t, 'tsfc vs B.csv');