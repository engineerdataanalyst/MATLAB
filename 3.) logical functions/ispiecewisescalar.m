function bool = ispiecewisescalar(a)
  % --------------------------
  % - returns true if an array
  %   is a piecewise scalar
  % --------------------------
  narginchk(1,1);
  bool = issymscalar(a) && ispiecewise(a);
