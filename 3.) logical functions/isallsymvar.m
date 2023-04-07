function bool = isallsymvar(a)
  % ------------------------
  % - returns true if all
  %   elements of an array
  %   are symbolic variables
  % ------------------------
  narginchk(1,1);
  bool = all(issymvar(a), 'all');
