function bool = issquare(a)
  % --------------------------
  % - returns true if an array
  %   is a square matrix
  % --------------------------
  narginchk(1,1);
  bool = isMatrix(a) && (Height(a) == Width(a));
