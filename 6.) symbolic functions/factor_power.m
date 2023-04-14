function a = factor_power(a, n)
  % --------------------------
  % - raises each factor
  %   of a symbolic expression
  %   to a certain power
  %   separately and then
  %   multiplies the factors
  % --------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    n sym;
  end
  % check the symbolic function arguments
  if ~isequalargnames(a, n)
    error(message('symbolic:symfun:InputMatch'));
  end
  % check the argument dimensions
  if ~compatible_dims(a, n)
    error('input arguments must have compatible dimensions');
  end
  [a n] = scalar_expand(a, n);
  % check for empty arguments
  emptys = cellfun(@isEmpty, {a n});
  if any(emptys)
    return;
  end
  %% raise each factor to the given power
  func = @(A, N) prod(factor(A).^N);
  answer = arrayfun(func, formula(a), formula(n));
  if issymfun(a)
    a(argnames(a)) = answer;
  elseif issymfun(n)
    a(argnames(n)) = answer;
  else
    a = answer;
  end
