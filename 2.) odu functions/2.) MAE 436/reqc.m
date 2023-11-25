classdef reqc < handle
% design requirements class for the compensators
  properties (Constant, Hidden)    
    rtype_error_msg = 'a root must be a "zero" or "pole"';
    rval_error_msg = 'all roots must be negative';
    time_error_msg = 'time to improve must be "peak", "rise", or "settling"';
    factor_error_msg = 'all reducing factors must be >= 1';        
  end
  methods (Abstract)
    change(what, newval);
  end
  methods (Static)
    function zetaval = zetaf(os)
    % -returns the damping ratio
    %  at the given percent overshoot
      zetaval = -log(os/100)/sqrt(pi^2+log(os/100)^2);
    end
    function osval = osf(zeta)
      osval = exp(-zeta*pi/sqrt(1-zeta^2))*100;
    end    
    function tpval = tp(omega, zeta)
    % -returns the peak time at a given
    %  frequency (omega) and damping ratio (zeta)
      tpval = pi/(omega*sqrt(1-zeta^2));
    end
    function trval = tr(omega, zeta)
    % -returns the peak time at a given
    %  frequency (omega) and damping ratio (zeta)
      trval = (1+1.27*zeta)/omega; 
    end
    function tsval = ts(omega, zeta)
    % -returns the peak time at a given
    %  frequency (omega) and damping ratio
      tsval = 4/(omega*zeta);
    end    
    function sseval = sse(G)
      Keval = reqc.Ke(G);
      if stype(G) == 0        
        sseval = 1/(1+Keval);
      else
        sseval = 1/Keval;
      end
    end
    function Keval = Ke(G)
      if stype(G) == 0
        Gnew = G;
      else
        s = tf('s');
        for k = 1:stype(G)-1
          s = s*s;
        end
        Gnew = minreal(G*s);
      end      
      Keval = evalfr(Gnew,0);    
    end        
    function bool = check(varargin)
    % -checks the time to see if it
    %  either says 'peak', 'rise', or 'settling'
    %  or the root to see if it's < 0
      what = varargin{nargin};
      bool = true;
      if ~ischar(what)
        error('last argument must be a string');
      end
      for k = 1:nargin-1
        switch what
          case 'rtype'
            switch varargin{k}
              case 'pole'
              case 'zero'
              otherwise
                bool = false;
                break;
            end
          case 'rval'          
            if varargin{k} >= 0
              bool = false;
              break;
            end    
          case 'time'
            switch varargin{k}
              case 'peak'
              case 'rise'
              case 'settling'              
              otherwise
                bool = false;
                break;
            end 
          case 'factor'
            if varargin{k} < 1
              bool = false;
              break;
            end
          otherwise
            error('last argument must be "rtype", "rval", "time", or "factor"');            
        end
      end       
    end    
    function legendlist = legend(complist)
    % -returns a cell array containing
    %  a list of compensator names
    %  for a legend
      legendlist = cell(0);
      complen = length(complist);
      for k = 1:complen
        switch complist{k}
          case 'un'
          case 'lag'
          case 'lead'
          case 'laglead'
          otherwise
            error('input arguments must be "un", "lag", "lead", or "laglead"');
        end
        str = 'compensated';
        space = ' ';
        switch complist{k}
          case 'un'
            space = '';
          case 'laglead'
            complist{k} = 'lag-lead';
        end           
        legendlist{k} = [complist{k} space str];    
      end
    end
    function plot(Input, varargin)
      tfsize = arg.size({'tf', 'zpk'}, varargin{:});
      vararglen = length(varargin);
      lastarg = varargin{vararglen};      
      t = 0:0.001:10';
      if strcmp(lastarg, 'sse')
        str = Input;
        if strcmp(Input, 'para')
          str = [Input 'bolic'];
        end
        titlestr = {'Error Plot', [['(' str] ' input)']};
      else
        switch Input
          case 'step'
            titlestr = 'Step Response';
          case 'ramp'
            titlestr = 'Ramp Response';
          case 'para'
            titlestr = 'Parabolic Response';
          otherwise
            error('input must be "step", "ramp", or "para"');
        end
      end          
      legendlist = cell(0);            
      argo = arg({'t', 'title', 'legend'},{t, titlestr, legendlist});
      if strcmp(lastarg, 'sse')
        arglen = vararglen-1;
      else
        arglen = vararglen;
      end            
      [t titlestr legendlist] = argo.set(varargin{tfsize+1:arglen});      
      legendlist = reqc.legend(legendlist);
      plotlist = {'t', t, 'title', titlestr, 'legend', legendlist};
      if strcmp(lastarg, 'sse')
        sse(Input, varargin{1:tfsize}, plotlist{:});
      else       
        switch Input
          case 'step'
            step(varargin{1:tfsize});
            title(titlestr);
              if ~isempty(legendlist)
                legend(legendlist);
              end             
          case 'ramp'
            ramp(varargin{1:tfsize}, plotlist{:});
          case 'para'
            para(varargin{1:tfsize}, plotlist{:});
        end
      end                           
    end      
  end     
end