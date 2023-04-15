function val = sing(x, a, n)
  % --------------------------
  % - the singularity function
  % --------------------------

  %% check the input arguments
  narginchk(3,3);
  if isTextScalar(x, ["char" "string" "cell of char"])
    x = Str2sym(x);
  end
  if isTextScalar(a, ["char" "string" "cell of char"])
    a = Str2sym(a);
  end
  if isTextScalar(n, ["char" "string" "cell of char"])
    n = Str2sym(n);
  end
  arglist = {x a n};
  numargs = cellfun(@isnumeric, arglist);
  symargs = cellfun(@issym, arglist);  
  scalarargs = cellfun(@isscalar, arglist);
  if ~any(numargs) && ~any(symargs)
    str = stack('input argument must be one of these:', ...
                '------------------------------------', ...
                '1.) a numeric array', ...
                '2.) a symbolic array', ...
                '3.) a symbolic string');
    error(str);
  end
  %% return the singularity function
  if isnumeric(n)
    if n >= 0
      val = (x-a)^n*u(x-a);
    else
      val = d(x-a);
    end
  else
    if ~all(scalarargs, 'all')
      str = stack('when passing symbolic arguments', ...
                  'they must all be scalars');
      error(str);
    end
    val = piecewise(n >= 0, (x-a)^n*u(x-a), d(x-a));
  end
