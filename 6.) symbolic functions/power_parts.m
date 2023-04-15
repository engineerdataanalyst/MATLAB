function [B N] = power_parts(a)
  % --------------------------
  % - returns the base and the
  %   exponent of a symbolic
  %   expression
  % --------------------------
  
  %% check the input argument
  arguments
    a sym;
  end
  %% compute the bases and exponents
  B = formula(a);
  N = sym.ones(Size(a));
  loc = isSymType(a, 'power');
  for k = find(loc(:)).'
    B(k) = children(index(a, k), 1);
    N(k) = children(index(a, k), 2);
  end
  if issymfun(a)
    B(argnames(a)) = B;
    N(argnames(a)) = N;
  end
