function [Glag Tlag lag] = lag1(G, req, varargin)
% ----------------------------------------------------------
% -Using root locus techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the lag compensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =req:      the design requirements (see help req1)
% =varargin: a variable list of arguments
%            1.) lagroot: the value for the lag pole
%            2.) guess:   the guessing value for the lag frequency  
%            3.) n:       the multiple of 360 degrees to use
% 
% -output arguments:
% ----------------
% =Glag:    the lag compensated open loop transfer function
% =Tlag:    the lag compensated closed loop transfer function
% =lag:     the lag compensated values (see help compvals1)
% ----------------------------------------------------------
  %% obtaining the necessary values
  % default arguments
  lagroot = {'pole', -0.01};
  argo = arg({'lagroot','guess','n'},{lagroot,-1,-1});
  for k = 1:length(varargin)
    switch varargin{k}
      case {'pole', 'lagpole'}
        varargin{k} = 'lagroot';
        varargin{k+1} = {'pole', varargin{k+1}};
      case {'zero', 'lagzero'}
        varargin{k} = 'lagroot';
        varargin{k+1} = {'zero', varargin{k+1}};
    end    
  end
  [lagroot guess n] = argo.set(varargin{:});
  % validity check 
  if ~req.check(lagroot{1}, 'rtype')
    error(req.rtype_error_msg);
  elseif ~req.check(lagroot{2}, 'rval')
    error(req.rval_error_msg);
  elseif ~req.check(req.ssef, 'factor')
    error(req.factor_error_msg);
  end
  % damping ratio
  zeta = req.zeta(1);  
  thetad = req.thetad(1);  
  %% meeting the error compuirements  
  [~, ~, un] = un1(G, req, 'guess', guess, 'n', n);
  Ke1 = un.Ke;
  sse1 = un.sse;
  sse2 = sse1/req.ssef;
  if stype(G) == 0
    Ke2 = (1-sse2)/sse2;
  else
    Ke2 = req.ssef*Ke1;
  end
  %% calculating the lead compensated point
  % updating the poles and zeros
  switch lagroot{1}
    case 'zero'
      zlag = lagroot{2};
      plag = zlag*(Ke1/Ke2);   
    case 'pole'
      plag = lagroot{2};
      zlag = plag*(Ke2/Ke1);    
  end
  [zeros poles] = zpkdata(G);
  poles = [cell2mat(poles)' plag];
  zeros = [cell2mat(zeros)' zlag];  
  % calculating the lead compensated transfer functions
  switch class(G)
    case 'tf'
      Gnew = minreal(tf(poly(zeros), poly(poles)));
    case 'zpk'
      Gnew = minreal(zpk(zeros, poles, 1));
  end  
  [rlag slag Klag] = req.r(Gnew, thetad, 'guess', guess, 'n', n);  
  [Glag Tlag] = newgain(Gnew, Klag);  
  %% recording the lag compensated values  
  lag = compvals1;
  lag.r = rlag;
  lag.s = slag;
  lag.K = Klag;
  lag.zlag = zlag;
  lag.plag = plag;  
  lag.tp = req.tp(rlag, zeta);
  lag.tr = req.tr(rlag, zeta);
  lag.ts = req.ts(rlag, zeta);
  lag.sse = req.sse(Glag);
  lag.Ke = req.Ke(Glag);    