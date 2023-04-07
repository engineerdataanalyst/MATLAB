function bool = islogscalar(a)
  % --------------------------
  % - returns true if an array
  %   is a logical scalar
  % --------------------------
  narginchk(1,1);
  bool = isScalar(a, 'logical');
