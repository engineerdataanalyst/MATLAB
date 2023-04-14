function f = factors(a, varargin)
  % ----------------------------------------------
  % - a slight variation of the factor function
  % - will return a cell array of symbolic vectors
  %   containing the output arguments
  %   of the factor function corresponding
  %   to each element of a symbolic array
  % ----------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    varargin;
  end
  % check for symbolic functions  
  if issymfun(a)    
    a = formula(a);  
  end
  %% call the original factor function for empty or scalar arrays
  if numel(a) <= 1
    if isscalar(a)
      f = factor(a);
    else
      f = a;
    end
    return;
  end
  %% compute the factors
  f = cell(size(a));
  for k = 1:numel(a)
    f{k} = factor(a(k), varargin{:});
  end
  %% change to symbolic if possible
  if all(cellfun(@isscalar, f), 'all')
    f = sym(f);
  end
