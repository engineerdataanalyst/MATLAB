function bool = isanypiecewise(a)
  % ---------------------------
  % - returns true if any
  %   element of an array
  %   is a piecewise expression
  % ---------------------------
  narginchk(1,1);
  bool = any(ispiecewise(a), 'all');
