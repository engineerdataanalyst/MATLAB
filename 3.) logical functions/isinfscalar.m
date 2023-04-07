function bool = isinfscalar(a)
  % --------------------------
  % - returns true of an array
  %   is scalar with an
  %   infinite value
  % --------------------------
  narginchk(1,1);  
  bool = isScalar(a) && isinf2(a);
