function bool = isanynan(a)
  % -----------------------------
  % - returns true if any element
  %   of an array is Nan
  % -----------------------------
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
      bool = any(cellfun(@isnan2, a), 'all');
    else
      bool = cellfun(@isnan2, convert2row(a), 'UniformOutput', false);
      bool = any([bool{:}]);
    end
  else
    bool = any(isnan(a), 'all');
  end
