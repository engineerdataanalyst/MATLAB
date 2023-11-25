function [Glag Tlag lag] = lag2(G, req, varargin)
% ----------------------------------
% -Using frequency response techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the lag compensated system. 
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
  %% calculating the lag compensated transfer function
  % plotting the uncompensated system
  figure;  
  bode(Gun, logrange); grid;
  title('Uncompensated System'); 
  % obtaining the lag compensated frequency and magnitude 
  pm_new = req.pm+extra; 
  fprintf('\nFrom the "Uncompensated System" plot...');
  str1 = sprintf('\nenter the frequency at %.2f degrees: ', pm_new-180);
  str2 = sprintf('enter the M value at that frequency: ');
  omega = input(str1);
  M = input(str2); 
  fprintf('\n');
  % calculating T and alpha
  T = 1/(0.10*omega);
  alpha = 10^(M/20);
  % obtaining the transfer functions
  Glag = Gun*tf([T 1],[T*alpha 1]);
  if isa(Gun, 'zpk')
    Glag = zpk(Glag);
  end
  Tlag = feedback(Glag,1);
  [~, ~, Klag] = zpkdata(Glag);  
  [gm pm] = margin(Glag);    
  %% recording the lag compensated values  
  lag = compvals2;
  lag.K = Klag;
  lag.omega = omega;
  lag.T = T;
  lag.alpha = alpha;
  lag.gm = 20*log10(gm);
  lag.pm = pm;
  lag.sse = req2.sse(Glag);
  lag.Ke = req2.Ke(Glag);   