function bool = isallsymunit(a)
  % ----------------------
  % - returns true if all
  %   elements of an array
  %   are symbolic units
  % ----------------------
  narginchk(1,1);
  bool = all(issymunit(a), 'all');
