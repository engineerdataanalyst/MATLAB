function [Gun Tun un] = un2(G, req, logrange)
% ----------------------------------
% -Using frequency response techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the uncompensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =req:      the design requirements (see help req2)
% =logrange: the range of frequency values for the bode plot
% 
% -output arguments:
% ----------------
% =Gun: the uncompensated open loop transfer function
% =Tun: the uncompensated closed loop transfer function
% =un:  the uncompensated values (see help compvals)
% ----------------------------------
  %% meeting the error requirements
  % validity check 
  if ~req2.check(req.ssef, 'factor')
    error(req2.factor_error_msg);
  end
  % calculating the error values
  sse1 = req2.sse(G);
  Ke1 = req2.Ke(G);  
  sse2 = sse1/req.ssef;
  if stype(G) == 0
    Ke2 = (1-sse2)/sse2;
  else
    Ke2 = req.ssef*Ke1;
  end    
  %% caluclating the uncompensated transfer functions
  Gun = (Ke2/Ke1)*G;
  Tun = feedback(Gun,1);  
  %% recording the uncompensated values
  [~, ~, Kun] = zpkdata(Gun);
  [gm pm] = margin(Gun);   
  un = compvals2;
  un.K = Kun;
  un.gm = 20*log10(gm);
  un.pm = pm;
  un.sse = req2.sse(Gun);  
  un.Ke = req2.Ke(Gun);  