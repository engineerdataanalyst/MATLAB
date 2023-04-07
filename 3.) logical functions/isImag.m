function bool = isImag(a)
  % ----------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are imaginary numbers
  % ----------------------------
  narginchk(1,1);
  bool = ~isReal(a);
