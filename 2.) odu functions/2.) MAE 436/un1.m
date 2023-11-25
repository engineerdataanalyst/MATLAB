function [Gun Tun un] = un1(G, req, varargin)
% -Using root locus techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions for the uncompensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =zeta:     the design requirements (see help req1)
% =varargin:
% 
% -output arguments:
% ----------------
% =Gun:    the lag compensated open loop transfer function
% =Tun:    Glag without the lag compensated gain
% =uncomp: the uncompensated values (see help compvals1)
  zeta = req.zeta(1);
  thetad = req.thetad(1);  
  [run sun Kun] = req1.r(G, thetad, varargin{:});
  [Gun Tun] = newgain(G, Kun);
  un = compvals1;
  un.r = run;
  un.s = sun;
  un.K = Kun;
  un.tp = req1.tp(run, zeta);
  un.tr = req1.tr(run, zeta);
  un.ts = req1.ts(run, zeta);
  un.sse = req1.sse(Gun);
  un.Ke = req1.Ke(Gun);