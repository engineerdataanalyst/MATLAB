function bool = hasUnits(a)
  % ------------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of a symbolic array
  %   that has symbolic units
  % ------------------------------
  narginchk(1,1);
  if ~issym(a)
    bool = false;
    return;
  elseif issymfun(a)
    a = formula(a);
  end
  charPattern = alphanumericsPattern | "_";
  pattern = "unit::"+asManyOfPattern(charPattern, 1);
  bool = hasSymType(a, 'unit') | contains(string(a), pattern);
