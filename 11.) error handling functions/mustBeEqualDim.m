function mustBeEqualDim(a, b)
  if isTextScalar(a)
    a = {a};
  end
  if isTextScalar(b)
    b = {b};
  end
  if ~isequaldim(a, b)
    aname = inputname(1);
    bname = inputname(2);
    if isempty(aname)
      aname = 'arg1';
    end
    if isempty(bname)
      bname = 'arg2';
    end
    str = stack('', ...
                '''%s'' must have the same dimensions as ''%s''');
    error(str, aname, bname);
  end
