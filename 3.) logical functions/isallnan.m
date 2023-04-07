function bool = isallnan(a)
  % ------------------------------
  % - returns true if all elements
  %   of an array are NaN
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
      bool = all(cellfun(@isnan2, a), 'all');
    else
      bool = cellfun(@isnan2, convert2row(a), 'UniformOutput', false);
      bool = all([bool{:}]);
    end
  else
    bool = all(isnan(a), 'all');
  end
