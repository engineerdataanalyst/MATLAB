classdef arg < handle
  properties
    argnames;
    defvals;
  end
  methods
    function obj = arg(argnames, defvals)
      obj.argnames = argnames;
      obj.defvals = defvals;
    end
    function varargout = set(obj, varargin)
      varargout = obj.defvals;
      namelen = length(obj.argnames);      
      deflen = length(obj.defvals);
      arglen = length(varargin);
      if ~arg.check(varargin{:})
        error('input arguments are invalid');
      elseif deflen < namelen
        error('not enough default values');
      elseif deflen > namelen
        error('too many default values');
      end
      for k = 1:2:arglen
        nameloc = find(ismember(obj.argnames, varargin{k}));
        if ~isempty(nameloc)
          varargout{nameloc} = varargin{k+1};
        elseif ischar(varargin{k})          
          str = sprintf('invalid argument name: "%s"', varargin{k});
          error(str);          
        end        
      end
    end
  end
  methods (Static)
    function bool = check(varargin)
    % returns true if a variable arguments list
    % alternates from char to some other data type 
      bool = true;
      arglen = length(varargin);      
      if arglen == 0
        return;
      end
      for k = 1:nargin
        if rem(k,2) ~= 0 && ~ischar(varargin{k})
          bool = false;
          break;
        end
      end
    end     
    function val = size(classname, varargin)
    % -returns the number of times an argument
    %  of a specific class type appears in a
    %  variable argument list
    % -stops when it reaches the first occurance
    %  of not being the target class  
      val = 0;
      vararglen = length(varargin);
      for k = 1:vararglen                 
        if ~strcmp(class(varargin{k}), classname)
          break;      
        end
        val = val+1;
      end
    end      
  end
end