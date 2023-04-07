function bool = issym(a)
  % --------------------------
  % - returns true if an array
  %   is a symbolic array
  % --------------------------
  narginchk(1,1);
  bool = isa(a, 'sym');
