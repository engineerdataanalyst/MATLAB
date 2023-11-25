function [Glead Tlead lead] = lead2(G, req, varargin)
% ----------------------------------
% -Using frequency response techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the lead compensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =req:      the design requirements (see help req)
% =varargin: a variable list of arguments
%            1.) extra: additional phase to add to the phase margin
%            2.) logrange: the range of frequency values for the bode plot
% 
% -output arguments:
% ----------------
% =Glag: the lag compensated transfer function
% =Tlag: the lag compensated closed loop transfer function
% =lag:  the lag compensated values (see help compvals2)
% ----------------------------------
  %% obtaining the necessary values
  argo = arg({'extra','logrange'},{10,logspace(-4,4,1000)});
  [extra logrange] = argo.set(varargin{:});  
  Gun = un2(G, req, logrange);  
  %% calculating the lead compensated transfer function
  % plotting the uncompensated system
  figure;  
  bode(Gun, logrange); grid;
  title('Uncompensated System'); 
  % obtaining the lead compensated frequency and magnitude  
  pma_old = input('\nenter the phase margin angle (M = 0): ');  
  pm_old = pma_old+180; 
  pm_new = req.pm+extra;
  % calculating beta
  if pm_new < pm_old
    error('uncompensated phase margin is larger');
  end
  phimax = pm_new-pm_old;
  f = @(x) phimax-req.phimax(x);
  beta = fzero(f, [0 1]);
  % obtaining max frequency (omega_max)
  Mmax = req.Mmax(beta);
  M = -20*log10(Mmax);  
  str = sprintf('enter the frequency at M = %.2f dB: ', M);
  omega_max = input(str);
  fprintf('\n');
  % calculating T
  T = 1/(omega_max*sqrt(beta));
  % obtaining the transfer functions  
  Glead = Gun*tf([T 1],[T*beta 1]);
  if isa(Gun, 'zpk')
    Glead = zpk(Glead);
  end
  Tlead = feedback(Glead,1);
  [~, ~, Klead] = zpkdata(Glead);
  [gm pm] = margin(Glead);  
  %% recording the lag compensated values  
  lead = compvals2;
  lead.K = Klead;
  lead.omega = omega_max;
  lead.T = T;
  lead.beta = beta;
  lead.gm = 20*log10(gm);
  lead.pm = pm; 
  lead.sse = req2.sse(Glead);  
  lead.Ke = req2.Ke(Glead);     