function anew = array2symstr(a)
  % ---------------------------
  % - converts an array to a
  %   symbolic character vector
  % ---------------------------
  narginchk(1,1);
  anew = char(array2sym(a));
  if isstring(a)
    anew = string(anew);
  end
