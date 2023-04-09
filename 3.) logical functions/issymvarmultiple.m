function bool = issymvarmultiple(a, options)
  % ----------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are numeric multiples
  %   of symbolic variables
  % ----------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    options.CountZero (1,1) logical = false;
  end
  % check for symbolic functions
  if issymfun(a)
    a = formula(a);
  end
  % check the zero flag
  CountZero = options.CountZero;
  %% check the array
  if ~issym(a) || isempty(a)
    bool = false;
    return;
  end
  symnums = issymnum(a);
  bool = false(size(a));
  if CountZero
    bool(isAlways(release(a) == 0, 'Unknown', 'false')) = true;
  end
  if any(~symnums, 'all')
    func = @(arg) arg/symvar(arg, 1);  
    ratio = arrayfun(func, a(~symnums));
    bool(~symnums) = isSymType(ratio, 'constant');
  end
