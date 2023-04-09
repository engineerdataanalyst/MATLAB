function bool = issymunitscalar(a)
  % ---------------------------
  % - returns true if an array
  %   is a symbolic unit scalar  
  % ---------------------------
  narginchk(1,1);
  bool = issymscalar(a) && issymunit(a);
