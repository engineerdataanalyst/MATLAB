classdef req1 < reqc
%  design requirements class for compensators
% (using root locus techniques) #1   
  properties
    zeta;
    os;
    thetad;
    timef = {'settling', 1};
    ssef = 1;
  end
  methods %public methods
    function obj = req1(varargin)
    % -class constructor.
    %  sets the design requirements
      trans = {'os', 20};
      timef = {'settling', 1};
      ssef = 1;
      argo = arg({'trans','timef','ssef'},{trans,timef,ssef});      
      [trans timef ssef] = argo.set(varargin{:});
      if iscell(trans)
        obj.change(trans{:});
      else
        obj.change(trans);
      end    
      obj.change('timef', timef);
      obj.change('ssef', ssef);            
    end
    function obj = change(obj, what, newval)
      n = length(what);
      lastchar = what(n);
      whatval = what(1:n-1);
      switch lastchar
        case '1'
        case '2'
          whatval = what(1:n-1);
        otherwise
          whatval = what;
      end
      switch whatval
        case 'zeta'
          if newval < 0 || newval > 1
            error('zeta can only be in the range of 0-1');
          end
          zeta = newval;
          os = req1.osf(zeta);
          thetad = req1.thetadf(zeta);
        case 'os'
          if newval < 0 || newval > 100
            error('os can only be in the range of 0-100 percent');
          end
          os = newval;
          zeta = req1.zetaf(os);         
          thetad = req1.thetadf(zeta);
        case 'thetad'
          if newval < 90 || newval > 180
            error('thetad can only be in the range of 90-180 degrees');
          end
          thetad = newval;
          zeta = req1.zetaf1(thetad);
          os = req1.osf(zeta);
        case 'timef'          
          switch class(newval)
            case 'cell'
              if ~req1.check(newval{1}, 'time')
                error(req1.time_error_msg);
              elseif ~req1.check(newval{2}, 'factor')
                error(req1.factor_error_msg);
              end
              obj.timef = newval;              
            case 'char'
              if ~req1.check(newval, 'time');
                error(req1.time_error_msg);
              end
              obj.timef{1} = newval;             
            case 'double'
              if ~req1.check(newval, 'factor');
                error(req1.factor_error_msg);
              end
              obj.timef{2} = newval;            
          end
        case 'ssef'
          if ~isa(newval, 'double')
            error('second argument must be a number');
          elseif ~req1.check(newval, 'factor')
            error(req1.factor_error_msg);
          end
          obj.ssef = newval;          
        otherwise
          error('we can only change "zeta", "os", "thetad", "timef", or "ssef"');          
      end
      if ~strcmp(whatval, 'timef') && ~strcmp(whatval, 'ssef') 
        switch lastchar
          case '1'
            obj.zeta(1) = zeta;
            obj.os(1) = os;
            obj.thetad(1) = thetad;
          case '2'
            obj.zeta(2) = zeta;
            obj.os(2) = os;
            obj.thetad(2) = thetad;
          otherwise
            obj.zeta(1) = zeta;
            obj.zeta(2) = zeta;
            obj.os(1) = os;
            obj.os(2) = os;
            obj.thetad(1) = thetad;
            obj.thetad(2) = thetad;
        end
      end      
    end   
  end
  methods (Static) %static methods
    function thetadval = thetadf(zeta)
    % -returns the damping ratio angle
    %  at the given damping ratio
      thetadval = 180-acosd(zeta);
    end
    function zetaval = zetaf1(thetad)
    % -returns the damping ratio
    %  at the given damping ratio angle
      zetaval = cosd(180-thetad);
    end
    function [thetaval Kval] = theta(r, thetad, zeros, poles)
    % -returns the sum of the angles (thetaval) and the gain (Kval)
    %  of the poles and zeros corresponding the given frequency (r)
      if isa(zeros, 'cell')
        zeros = cell2mat(zeros)';
      end
      if isa(poles, 'cell')
        poles = cell2mat(poles)';
      end      
      nzeros = length(zeros);
      npoles = length(poles);              
      thetaval = 0;
      Kval = 1;
      for k = 1:nzeros       
        y = r*sind(thetad); 
       if ~isreal(zeros(k))
          y = y-imag(zeros(k)); 
        end     
        x = r*cosd(thetad)-real(zeros(k));        
        thetaval = thetaval+atan2(y,x)*(180/pi);
        Kval = Kval/sqrt(x^2+y^2);        
      end    
      for k = 1:npoles    
        y = r*sind(thetad); 
        if ~isreal(poles(k))
          y = y-imag(poles(k));
        end      
        x = r*cosd(thetad)-real(poles(k));        
        thetaval = thetaval-atan2(y,x)*(180/pi);        
        Kval = Kval*sqrt(x^2+y^2);        
      end      
    end
    function [rval sval Kval] = r(G, thetad, varargin)
    % -returns the frequency (rval), point (sval), and gain(Kval)
    %  corresponding to the given damping ratio (zeta) 
    %  of the system (G)  
      argo = arg({'guess','n'},{-1,-1});
      [guess n] = argo.set(varargin{:});
      [zeros poles] = zpkdata(G);             
      f = @(rval) req1.theta(rval, thetad, zeros, poles)-(2*n+1)*180;
      rval = fzero(f, guess);
      sval = rval*cosd(thetad)+rval*sind(thetad)*1i;
      [~, Kval] = req1.theta(rval, thetad, zeros, poles);  
    end
  end    
end