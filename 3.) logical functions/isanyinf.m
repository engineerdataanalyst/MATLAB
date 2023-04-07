function bool = isanyinf(a)
  % -----------------------------
  % - returns true if any element
  %   of an array is infinite
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
      bool = any(cellfun(@isinf2, a), 'all');
    else
      bool = cellfun(@isinf2, convert2row(a), 'UniformOutput', false);
      bool = any([bool{:}]);
    end
  else
    bool = any(isinf(a), 'all');
  end
