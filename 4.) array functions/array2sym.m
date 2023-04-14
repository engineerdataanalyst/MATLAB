function a = array2sym(a)
  % ---------------------
  % - converts an array
  %   to a symbolic array
  % ---------------------
  narginchk(1,1);
  if islogical(a)
    a = log2sym(a);
  elseif isTextScalar(a, ["char" "string" "cell of char"])
    a = Str2sym(a);
  elseif iscategorical(a)
    a = array2sym(cellstr(a));
  elseif iscell(a) || istabular(a)
    a = sym(array2cellsym(a));
  elseif ~issym(a)
    a = sym(a);
  end 
