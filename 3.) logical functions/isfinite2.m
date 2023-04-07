function bool = isfinite2(a)
  % ---------------------------------------------
  % - a slight variation of the isfinite function
  % - will convert incompatible data types
  %   to the necessary type and call
  %   the regular isfinite function accordingly
  % ---------------------------------------------
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
      bool = cellfun(@isfinite, a);
    else
      bool = cellfun(@isfinite, a, 'UniformOutput', false);
    end
  else
    bool = isfinite(a);
  end
