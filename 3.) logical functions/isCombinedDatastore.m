function bool = isCombinedDatastore(a)
  % -------------------------------
  % - returns true if an array
  %   is a CombinedDatastore object
  % -------------------------------
  narginchk(1,1);
  bool = isa(a, 'matlab.io.datastore.CombinedDatastore');
