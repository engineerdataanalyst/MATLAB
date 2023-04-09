function bool = issymvarscalar(a)
  % -------------------------------
  % - returns true if an array
  %   is a symbolic variable scalar
  % -------------------------------
  narginchk(1,1);
  bool = issymscalar(a) && issymvar(a);
