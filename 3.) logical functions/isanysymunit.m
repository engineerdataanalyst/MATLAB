function bool = isanysymunit(a)
  % ---------------------
  % - returns true if any
  %   element of an array
  %   is a symbolic unit
  % ---------------------
  narginchk(1,1);
  bool = any(issymunit(a), 'all');
