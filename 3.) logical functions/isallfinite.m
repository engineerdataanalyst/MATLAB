function bool = isallfinite(a)
  % ------------------------------
  % - returns true if all elements
  %   of an array are finite
  % ------------------------------
  narginchk(1,1);
  if istabular(a)
    a = table2cell(a);
  elseif issymfun(a)
    a = formula(a);
  end
  if iscell(a)
    symfuns = cellfun(@issymfun, a);
    a(symfuns) = cellfun(@formula, a(symfuns), 'UniformOutput', false);
    if all(cellfun(@isscalar, a), 'all')
      bool = all(cellfun(@isfinite, a), 'all');
    else
      bool = cellfun(@isfinite, convert2row(a), 'UniformOutput', false);
      bool = all([bool{:}]);
    end
  else
    bool = all(isfinite(a), 'all');
  end
