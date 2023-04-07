function bool = iscellsymvarscalar(a)
  % ---------------------------
  % - returns true if an array
  %   is a cell array of
  %   symbolic variable scalars
  % ---------------------------
  narginchk(1,1);
  if ~iscell(a) || isEmpty(a)
    bool = false;
  else
    bool = all(cellfun(@issymvarscalar, a), 'all');
  end
