function bool = issymunit(a)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are symbolic units
  % -------------------------
  narginchk(1,1);
  if ~issym(a) || isEmpty(a)
    bool = false;  
  else
    bool = isUnit(a);
  end
