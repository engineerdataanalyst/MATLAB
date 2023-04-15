function val = sumnot(f, varargin)
  % --------------------------------------------
  % - redefinition of matlabs's symprod function
  % - will actually multiply each factor
  %   in the series instead of using technical
  %   calculations
  % --------------------------------------------
    
    %% check the input arguments
    narginchk(2,3);
    persistent nargin2str;
    persistent nargin3str;
    if isempty(nargin2str)
      nargin2str = stack('when passing two arguments,', ...
                         'the second argument must be', ...                         
                         'one of these values:', ...
                         '--------------------', ...
                         '1.) a numeric vector of length 2', ...
                         '2.) a symbolic vector of length 2', ...
                         '    with no variables');
    end
    if isempty(nargin3str)
      nargin3str = stack('when passing three arguments,', ...
                         'the %s argument must be', ...
                         'one of these values:', ...
                         '--------------------', ...
                         '1.) a numeric scalar', ...
                         '2.) a symbolic scalar', ...
                         '    with no variables');
    end
    if ~isa(f, 'function_handle')
      str = stack('first argument must be', ...
                  'a function handle');
      error(str);
    end    
    symargs = any(cellfun(@issym, varargin));
    if symargs
      varlist = cellfun(@symvar, varargin, 'UniformOutput', false);
      emptyvars = cellfun(@isempty, varlist);
    end        
    if nargin == 2
      if symargs
        if ~emptyvars
          error(nargin2str);
        end
      end
      validarg = isnumvector(varargin{1}, 2) || ...
                 issymvector(varargin{1}, 2);
      if ~validarg
        error(nargin2str); 
      end    
      [start finish] = deal(varargin{1}(1), varargin{1}(2)); 
    else      
      for k = {1 2; 'second' 'third'}
        if symargs
          if ~emptyvars(k{1})
            error(nargin3str, k{2});
          end
        end
        validarg = isnumscalar(varargin{k{1}}) || ...
                   issymscalar(varargin{k{1}});
        if ~validarg
          error(nargin3str, k{2});
        end
      end
      [start finish] = deal(varargin{:}); 
    end     
    %% return the sum
    val = 0;
    for k = start:finish
      val = val+f(k);
    end    
