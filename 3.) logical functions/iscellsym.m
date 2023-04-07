function bool = iscellsym(a)
  % --------------------------
  % - returns true if an array
  %   is a cell array of
  %   symbolic arrays
  % --------------------------
  narginchk(1,1);
  if ~iscell(a) || isEmpty(a)
    bool = false;
  else
    bool = all(cellfun(@issym, a), 'all');
  end
