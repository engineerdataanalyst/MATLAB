function bool = isallinf(a)
  % ------------------------------
  % - returns true if all elements
  %   of an array are infinite
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
      bool = all(cellfun(@isinf2, a), 'all');
    else
      bool = cellfun(@isinf2, convert2row(a), 'UniformOutput', false);
      bool = all([bool{:}]);
    end
  else
    bool = all(isinf(a), 'all');
  end
