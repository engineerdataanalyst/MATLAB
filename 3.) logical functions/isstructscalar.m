function bool = isstructscalar(a)
  % --------------------------
  % - returns true if an array
  %   is a struct scalar
  % --------------------------
  narginchk(1,1);
  bool = isScalar(a, 'struct');
