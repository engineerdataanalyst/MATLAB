function bool = isdatastore(a)
  % ---------------------------
  % - returns true if an array
  %   is a datastore object
  % ---------------------------
  narginchk(1,1);
  bool = isa(a, 'matlab.io.datastore.Datastore');
