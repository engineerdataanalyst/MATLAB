function bool = isnan2(a)
  % ------------------------------------------
  % - a slight variation of the isnan function
  % - will convert incompatible data types
  %   to the necessary type and call
  %   the regular isnan function accordingly
  % ------------------------------------------
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
      bool = cellfun(@isnan, a);
    else
      bool = cellfun(@isnan, a, 'UniformOutput', false);
    end
  else
    bool = isnan(a);
  end
