function bool = isanysymvar(a)
  % ------------------------
  % - returns true if any
  %   element of an array
  %   is a symbolic variable
  % ------------------------
  narginchk(1,1);
  bool = any(issymvar(a), 'all');
