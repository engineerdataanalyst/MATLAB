function a = array2string(a)
  % -------------------
  % - converts an array
  %   to a string array  
  % -------------------
  narginchk(1,1);
  if islogical(a) || isnumeric(a) || issym(a) || ...
     isTextArray(a) || iscategorical(a)
    a = string(a);
  elseif iscell(a)
    a = string(array2cellstr(a));
  elseif istabular(a)
    a = array2string(table2cell(a));
  elseif ~isstring(a)
    a = string(missing);
  end
