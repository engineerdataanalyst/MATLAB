function bool = isequalargnames(a, options)
  % -------------------------------------
  % - returns true if all input arguments
  %   have the same symbolic function
  %   input arguments
  % -------------------------------------

  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    a;
  end
  arguments
    options.CheckSymfunsOnly (1,1) logical = true;
  end
  % check the number of input arguments
  narginchk(1,inf);
  % check the symbolic function only flag
  CheckSymfunsOnly = options.CheckSymfunsOnly;
  %% check the symbolic function input arguments
  symbolics = cellfun(@issym, a);
  symfuns = cellfun(@issymfun, a);
  if nargin == 1
    bool = true;
  elseif ~all(symbolics)
    bool = CheckSymfunsOnly;
  else
    uniform = {'UniformOutput' false};    
    args = cellfun(@argnames, a, uniform{:});
    if CheckSymfunsOnly
      bool = isallequal(args(symfuns));
    else
      bool = isallequal(args);
    end
  end
