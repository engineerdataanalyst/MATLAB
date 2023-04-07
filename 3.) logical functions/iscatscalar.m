function bool = iscatscalar(a)
  % --------------------------
  % - returns true if an array
  %   is a categorical scalar
  % --------------------------
  narginchk(1,1);
  bool = isScalar(a, 'categorical');
