function bool = isunique(a)
  % --------------------------
  % - returns true if an array
  %   contains unique values
  % --------------------------
  narginchk(1,1);
  try
    if istabular(a)
      a = table2cell(a);
    elseif issymfun(a)
      a = formula(a);
    end
    if isempty(a)
      bool = true;
    else
      bool = isequal(sort(a(:)), unique(a(:)));
    end
  catch
    str = stack('function call to ''isunique'' failed', ...
                'because the array cannot be sorted');
    error(str);
  end
