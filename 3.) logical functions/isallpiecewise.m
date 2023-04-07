function bool = isallpiecewise(a)
  % ---------------------------
  % - returns true if all
  %   elements of an array
  %   are piecewise expressions
  % ---------------------------
  narginchk(1,1);
  bool = all(ispiecewise(a), 'all');
