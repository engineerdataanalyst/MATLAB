function bool = isallequal(a)
  % ------------------------------
  % - returns true if all elements
  %   of an array are equal
  % ------------------------------
  narginchk(1,1);
  if istabular(a)
    a = table2cell(a);
  elseif issymfun(a)
    a = array2cellsym(a);
  elseif ~iscell(a)
    a = num2cell(a);
  end
  if isscalar(a) || isempty(a)
    bool = true;
  else
    bool = isequal(a{:});
  end
