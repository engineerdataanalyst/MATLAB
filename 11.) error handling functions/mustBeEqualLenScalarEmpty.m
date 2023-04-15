function mustBeEqualLenScalarEmpty(a, b)
  if isTextScalar(a)
    a = {a};
  elseif issymfun(a)
    a = formula(a);
  end
  if isTextScalar(a)
    a = {a};
  elseif issymfun(b)
    b = formula(b);
  end
  if ~isequallen(a, b) && ~isscalar(a) && ~isempty(a)
    aname = inputname(1);
    bname = inputname(2);
    if isempty(aname)
      aname = 'arg1';
    end
    if isempty(bname)
      bname = 'arg2';
    end
    str = stack('', ...
                '''%s'' must have the same dimensions as ''%s''', ...
                'or must be a scalar or empty array');
    error([newline str], aname, bname);
  end
