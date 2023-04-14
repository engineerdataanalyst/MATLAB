function a = array2cell(a)
  % -------------------
  % - converts an array
  %   to a cell array
  % -------------------
  narginchk(1,1);
  if issym(a)
    a = array2cellsym(a);
  elseif ischar(a) || iscategorical(a)
    a = cellstr(a);
  elseif istabular(a)
    a = table2cell(a);
  elseif ~iscell(a)
    a = num2cell(a);
  end
