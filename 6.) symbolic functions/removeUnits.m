function a = removeUnits(a)
  % ----------------------------
  % - removes the symbolic units
  %   from a symbolic array  
  % ----------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    a sym;
  end
  % check for symbolic functions
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  %% remove the symbolic units
  a = mapSymType(a, 'unit', @(~) 1);
  charPattern = alphanumericsPattern | "_";
  pattern = "unit::"+asManyOfPattern(charPattern, 1);
  for k = find(contains(string(a(:)), pattern)).'
    [expr cond] = branches(a(k));
    expr = replace(string(expr), pattern, "1");
    cond = replace(string(cond), pattern, "1");
    expr = cellfun(@array2sym, expr, 'UniformOutput', false);
    cond = cellfun(@array2sym, cond, 'UniformOutput', false);
    a(k) = branches2piecewise(expr, cond);
  end
  %% convert back to symbolic function if nessary
  if convert2symfun
    a(args) = a;
  end
