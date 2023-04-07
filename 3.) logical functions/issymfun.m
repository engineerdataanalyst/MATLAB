function bool = issymfun(a)
  % ------------------------------
  % - returns true if an array
  %   is a symbolic function array
  % ------------------------------
  narginchk(1,1);
  bool = isa(a, 'symfun');
