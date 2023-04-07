function bool = ispiecewise(a)
  % --------------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are piecewise expressions
  % --------------------------------
  narginchk(1,1);
  if ~issym(a) || isEmpty(a)
    bool = false;
  else
    bool = isSymType(a, 'piecewise');
  end
