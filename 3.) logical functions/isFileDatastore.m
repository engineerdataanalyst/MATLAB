function bool = isFileDatastore(a)
  % ---------------------------
  % - returns true if an array
  %   is a FileDatastore object
  % ---------------------------
  narginchk(1,1);
  bool = isa(a, 'matlab.io.datastore.FileDatastore');
