function bool = ishandleclass(a)
  % --------------------------
  % - returns true if an array
  %   is a handle class object
  % --------------------------
  narginchk(1,1);
  bool = isa(a, 'handle');
