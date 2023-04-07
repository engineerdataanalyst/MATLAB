function bool = iscellnum(a)
  % --------------------------
  % - returns true if an array
  %   is a cell array of
  %   numeric arrays
  % --------------------------
  narginchk(1,1);
  if ~iscell(a) || isEmpty(a)
    bool = false;
  else
    bool = all(cellfun(@isnumeric, a), 'all');
  end
