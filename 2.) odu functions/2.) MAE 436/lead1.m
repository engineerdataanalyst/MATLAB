function [Glead Tlead lead] = lead1(G, req, varargin)
% -----------------------------------------------------------
% -Using root locus techniques, returns the 
%  open loop (G) and closed loop (T) transfer
%  functions of the lead compensated system. 
% -Second order approximations are used
%  in this function
% 
% -input arguments:
% ----------------
% =G:        the open loop transfer function of the system
% =req:      the design requirements (see help req1)
% =varargin: a variable list of arguments
%            1.) lagroot: the value for the lag pole
%            2.) guess:   the guessing value for the lead frequency  
%            3.) n:       the multiple of 360 degrees to use                        
% 
% -output arguments:
% ----------------
% =Glead:    the lead compensated open loop transfer function
% =Tlead:    the lead compensated closed loop transfer function
% =lead:     the lead compensated values (see help compvals1)
% -----------------------------------------------------------
  %% obtaining the necessary values
  % default arguments
  leadroot = {'zero', -1};  
  argo = arg({'leadroot','guess','n'},{leadroot,-1,-1});
  for k = 1:length(varargin)
    if isa(varargin{k}, 'cell')
      continue;
    end
    switch varargin{k}
      case {'zero', 'leadzero'}
        varargin{k} = 'leadroot';
        varargin{k+1} = {'zero', varargin{k+1}};
      case {'pole', 'leadpole'}
        varargin{k} = 'leadroot';
        varargin{k+1} = {'pole', varargin{k+1}};
    end    
  end
  [leadroot guess n] = argo.set(varargin{:}); 
  % validity check 
  if ~req.check(leadroot{1}, 'rtype')
    error(req.rtype_error_msg);
  elseif ~req.check(leadroot{2}, 'rval')
    error(req.rval_error_msg);
  elseif ~req.check(req.timef{1}, 'time')
    error(req.time_error_msg);
  elseif ~req.check(req.timef{2}, 'factor')
    error(req.factor_error_msg);
  end
  % damping ratio
  zeta = req.zeta;
  thetad = req.thetad;  
  %% meeting the transient requirements  
  [Gun, ~, un] = un1(G, req, 'guess', guess, 'n', n);  
  switch req.timef{1}
    case 'peak'  
      tp = un.tp/req.timef{2};
      rlead = pi/(tp*sqrt(1-zeta(2)^2));      
      tr = req.tr(rlead, zeta(2));
      ts = req.ts(rlead, zeta(2));
    case 'rise'
      tr = un.tr/req.timef{2};
      rlead = (1+1.27*zeta(2))/tr;      
      tp = req.tp(rlead, zeta(2));
      ts = req.ts(rlead, zeta(2));
    case 'settling'
      ts = un.ts/req.timef{2};
      rlead = 4/(zeta(2)*ts);      
      tr = req.tr(rlead, zeta(2));
      tp = req.tp(rlead, zeta(2));     
  end  
  slead = rlead*cosd(thetad(2))+rlead*sind(thetad(2))*i;
  %% obtaining the lead compensated pole and zero
  % updating the poles and zeros
  [zeros poles] = zpkdata(G);
  zeros = cell2mat(zeros)';
  poles = cell2mat(poles)';  
  switch leadroot{1}
    case 'zero'    
      zlead = leadroot{2};      
      zeros = [zeros zlead];      
    case 'pole'                
      plead = leadroot{2};
      poles = [poles plead];          
  end
  % calculating the angles, poles, and zeros
  y = rlead*sind(thetad(2));
  x = abs(rlead*cosd(thetad(2)));  
  theta = req.theta(rlead, thetad(2), zeros, poles);
  % calculating the other root value
  switch leadroot{1}
    case 'zero'    
      thetalead = 180+theta; %zero angle
      plead = -y/tand(thetalead)-x;    
      poles = [poles plead];
    case 'pole'
      thetalead = -180-theta; %zero angle
      zlead = -y/tand(thetalead)-x;
      zeros = [zeros zlead];
  end      
  % calculating the lead compensated transfer functions
  switch class(G)
    case 'tf'
      Gnew = minreal(tf(poly(zeros), poly(poles)));
    case 'zpk'
      Gnew = minreal(zpk(zeros, poles, 1));
  end    
  [~, Klead] = req.theta(rlead, thetad(2), zeros, poles);
  [Glead Tlead] = newgain(Gnew, Klead);  
  %% recording the lead compensated values  
  lead = compvals1;
  lead.r = rlead;
  lead.s = slead;
  lead.K = Klead;
  lead.zlead = zlead;
  lead.plead = plead;
  lead.tp = tp;
  lead.tr = tr;
  lead.ts = ts;
  lead.sse = req.sse(Glead);
  lead.Ke = req.Ke(Glead);  