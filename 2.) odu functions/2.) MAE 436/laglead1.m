function [Glaglead Tlaglead laglead] = laglead1(G, req, varargin)
% --------------------------------------------------------------
% -Using root locus techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the lag-lead compensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =req:      the design requirements (see help req1)
% =varargin: a variable list of arguments
%            1.) lagroot: the value for the lag pole
%            2.) guess:   the guessing value for the laglead frequency  
%            3.) n:       the multiple of 360 degrees to use
% 
% -output arguments:
% ----------------
% =Glag: the lag-lead compensated open loop transfer function
% =Tlag: the lag-lead compensated closed loop transfer function
% =lag:  the lag-lead compensated values (see help compvals1)
% ---------------------------------------------------------------
  %% obtaining the necessary values
  % default arguments
  lagroot = {'pole', -0.01};
  leadroot = {'zero', -1};  
  argo = arg({'lagroot','leadroot','guess','n'},{lagroot,leadroot,-1,-1});
  for k = 1:length(varargin)
    if isa(varargin{k}, 'cell')
      continue;
    end
    switch varargin{k}
      case 'lagpole'
        varargin{k} = 'lagroot';
        varargin{k+1} = {'pole', varargin{k+1}};
      case 'leadzero'
        varargin{k} = 'leadroot';
        varargin{k+1} = {'zero', varargin{k+1}};
      case 'lagzero'
        varargin{k} = 'lagroot';
        varargin{k+1} = {'zero', varargin{k+1}};      
      case 'leadpole'
        varargin{k} = 'leadroot';
        varargin{k+1} = {'pole', varargin{k+1}};
    end    
  end  
  [lagroot leadroot guess n] = argo.set(varargin{:});
  % validity check  
  if ~req.check(lagroot{1}, leadroot{1}, 'rtype')
    error(req.rtype_error_msg);
  elseif ~req.check(lagroot{2}, leadroot{2}, 'rval')
    error(req.rval_error_msg);
  elseif ~req.check(req.timef{1}, 'time')
    error(req.time_error_msg);
  elseif ~req.check(req.timef{2}, req.ssef, 'factor')
    error(req.factor_error_msg);
  end
  % uncompensated and lead compensated transfer functions
  Gun = un1(G, req, 'guess', guess, 'n', n);
  [Glead, ~, lead] = lead1(G, req, 'leadroot', leadroot, 'guess', guess, 'n', n);
  % damping ratio
  zeta = req.zeta(2);
  thetad = req.thetad(2);  
  %% meeting the error requirements
  sse1 = req.sse(Gun);
  sse2 = req.sse(Glead);     
  rootf = req.ssef/(sse1/sse2);
  %% caluclating the lead compensated point
  % updating the poles and zeros  
  switch lagroot{1}
    case 'pole'
      plaglead = lagroot{2};
      zlaglead = plaglead*rootf;    
    case 'zero'
      zlaglead = lagroot{2};
      plaglead = zlaglead/rootf;    
  end
  [zeros poles] = zpkdata(Glead);
  zeros = [cell2mat(zeros)' zlaglead];  
  poles = [cell2mat(poles)' plaglead];  
  % calculating the transfer functions
  switch class(G)
    case 'tf'
      Gnew = minreal(poly(zeros), poly(poles));
    case 'zpk'
      Gnew = minreal(zpk(zeros, poles, 1));
  end  
  [rlaglead slaglead Klaglead] = req.r(Gnew, thetad, 'guess', guess, 'n', n);  
  [Glaglead Tlaglead] = newgain(Gnew, Klaglead);  
  %% recording the lag-lead compensated values  
  laglead = compvals1;
  laglead.r = rlaglead;
  laglead.s = slaglead;
  laglead.K = Klaglead;
  laglead.tp = req.tp(rlaglead, zeta);
  laglead.tr = req.tr(rlaglead, zeta);
  laglead.ts = req.ts(rlaglead, zeta);  
  laglead.zlag = zlaglead;
  laglead.plag = plaglead;
  laglead.zlead = lead.zlead;
  laglead.plead = lead.plead;
  laglead.sse = req.sse(Glaglead);
  laglead.Ke = req.Ke(Glaglead);