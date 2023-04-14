function a = array2cellsym(a)
  % -------------------------------
  % - converts an array to a
  %   cell array of symbolic arrays
  % -------------------------------
  narginchk(1,1);
  if istabular(a)
    a = table2cell(a);
  end
  if iscell(a) || isstring(a)
    cells = cellfun(@iscell, a);
    a(cells) = cellfun(@array2cellsym, a(cells), 'UniformOutput', false);
    a = cellfun(@array2sym, a, 'UniformOutput', false);
  elseif issymfun(a)
    args = argnames(a);
    af = formula(a);
    a = cell(size(af));
    for k = 1:numel(af)
      a{k}(args) = af(k);
    end  
  else
    a = num2cell(array2sym(a));
  end
