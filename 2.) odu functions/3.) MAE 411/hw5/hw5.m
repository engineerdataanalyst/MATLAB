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
tint = (1100:100:1800)'; %K
OPR = (4:2:30)';
PRC = sqrt(OPR);
nOPR = length(OPR);
ntint = length(tint);

% Subsonic Diffuser (Inlet)
Va = Ma*sqrt(ga*Ra*10^3*ta);
po1 = pa*(1+etaD*(ga-1)/2*Ma^2)^(ga/(ga-1));
to1 = ta*(1+(ga-1)/2*Ma^2);

% Devices
for j = 1:nOPR
  for k = 1:ntint
    % Low Pressure Compressor
    po2(j,k) = po1*PRC(j);
    to2(j,k) = to1*(1+(PRC(j)^((ga-1)/ga)-1)/etaC);
    wLPC(j,k) = cpoa*(to1-to2(j,k));
    
    % High Pressure Compressor
    po3(j,k) = po2(j,k)*PRC(j);
    to3(j,k) = to2(j,k)*(1+(PRC(j)^((ga-1)/ga)-1)/etaC);
    wHPC(j,k) = cpoa*(to2(j,k)-to3(j,k));
    
    % Combustion Chamber
    po4(j,k) = (1-dpob)*po3(j,k);
    to4(j,k) = tint(k);
    
    dh = @(i) h(i,to4(j,k))-h(i,to3(j,k));      
    Y(j,k) = (-Hrp-MC*dh(2)-MH/2*dh(3)+Ycc*dh(4))/(dh(4)+3.76*dh(5));
    f(j,k) = Mfuel/(4.76*Y(j,k)*Mair*etab);
    
    % High Pressure Turbine
    to5(j,k) = to4(j,k)+wHPC(j,k)/(etam*(1+f(j,k))*cpog);
    po5(j,k) = po4(j,k)*(1-(1-to5(j,k)/to4(j,k))/etat)^(gg/(gg-1));
    
    % Low Pressure Turbine
    to6(j,k) = to5(j,k)+wLPC(j,k)/(etam*(1+f(j,k))*cpog);
    po6(j,k) = po5(j,k)*(1-(1-to6(j,k)/to5(j,k))/etat)^(gg/(gg-1));
    
    % Converging Nozzle
    pspo6(j,k) = (1-1/etaN*(1-2/(gg+1)))^(gg/(gg-1));
    if pa/po6(j,k) <= pspo6(j,k)
      Me(j,k) = 1;
      pe(j,k) = po6(j,k)*pspo6(j,k);
      te(j,k) = to6(j,k)*2/(gg+1);
      re(j,k) = pe(j,k)/(Rg*te(j,k));      
    else
      pe(j,k) = pa;
      te(j,k) = to6(k)*(1-etaN*(1-(pe(j,k)/po6(k))^((gg-1)/gg)));
      re(j,k) = pe(j,k)/(Rg*te(j,k));
      Me(j,k) = sqrt((to6(j,k)/te(j,k)-1)*2/(gg-1));
    end
    Ve(j,k) = Me(j,k)*sqrt(gg*Rg*10^3*te(j,k));    
  end
end

% Performance Chart
Fs = (1+f).*Ve-Va+(pe-pa)*10^3.*(1+f)./(re.*Ve); %N/kg/sec
tsfc = f./Fs*3600; %kg/hour/N

filename = [pwd '5.) MATLAB\1.) odu classes\3.) MAE 411\hw5\hw5.xlsx'];
xlswrite(filename, Fs, 'Sheet1', 'C3');
xlswrite(filename, tsfc, 'Sheet1', 'C21');