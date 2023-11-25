classdef req2 < reqc
%  design requirements class for compensators
% (using frequency response techniques)    
  properties
    zeta;
    os;
    pm;   
    ssef = 1;             
  end
  methods %public methods
    function obj = req2(varargin)
    % -class constructor.
    %  sets the design requirements
      trans = {'os', 20};      
      ssef = 1;
      argo = arg({'trans','ssef'},{trans,ssef});      
      [trans ssef] = argo.set(varargin{:});
      if iscell(trans)
        obj.change(trans{:});
      else
        obj.change(trans);
      end     
      obj.change('ssef', ssef);    
    end
    function obj = change(obj, what, newval)
      switch what        
        case 'zeta'
          if newval < 0 || newval > 1
            error('zeta can only be in the range of 0-1');
          end 
          obj.zeta = newval;
          obj.pm = req2.pmf(obj.zeta);
          obj.os = req2.osf(obj.zeta);          
        case 'os'
          if newval < 0 || newval > 100
            error('os can only be in the range of 0-100 percent');
          end
          obj.os = newval;          
          obj.zeta = req2.zetaf(obj.os);
          obj.pm = req2.pmf(obj.zeta);
        case 'pm'
          if newval < 0 || newval > 180
            error('pm can only be in the range of 0-180 degrees');
          end          
          obj.pm = newval;
          obj.zeta = req2.zetaf2(obj.pm);
          obj.os = req2.osf(obj.zeta);
        case 'ssef'
          if ~isa(newval, 'double')
            error('second argument must be a number');
          elseif ~req1.check(newval, 'factor')
            error(req1.factor_error_msg);
          end
          obj.ssef = newval;         
        otherwise
          error('we can only change "zeta", "os", "pm" or "ssef"');          
      end
    end   
  end   
  methods (Static) %static methods
    function [pmval pmaval] = pmf(zeta)
    % -returns the phase margin
    %  and the corresponding phase angle
    %  at the given damping ratio
      pmval = atand(2*zeta./sqrt(-2*zeta.^2+sqrt(1+4*zeta.^4)));
      pmaval = pmval-180;
    end
    function zetaval = zetaf2(pm)
    % -returns the damping ratio
    %  at the given phase margin
      func = @(zeta) pm-req2.pmf(zeta);
      zetaval = fzero(func, [0 1]);
    end    
    function Mmaxval = Mmax(beta)
    % -returns the maximum amplitude
    %  at the given beta value for
    %  lead compensators
      Mmaxval = 1/sqrt(beta);
    end
    function phimaxval = phimax(beta)
    % -returns the maximum phase angle
    %  at the given beta value for
    %  lead compensators
      phimaxval = atand((1-beta)/(2*sqrt(beta)));
    end   
  end    
end %classdef