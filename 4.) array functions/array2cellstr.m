function anew = array2cellstr(a)
  % ---------------------------------
  % - converts an array to a
  %   cell array of character vectors  
  % ---------------------------------
  narginchk(1,1);
  if isTextArray(a, ["char" "string" "cell"]) || iscategorical(a)
    anew = cellstr(a);    
  elseif islogical(a)
    anew = cellstr(string(a));
  elseif isnumeric(a)
    anew = num2cellstr(a);
  elseif issym(a)
    anew = array2cellsymstr(a);
  elseif iscell(a)
    anew = cell(size(a));
    for k = 1:numel(a)
      if isTextScalar(a{k}, ["char" "string" "cell of char"]) || ...
         issymscalar(a{k}) || iscatscalar(a{k})
        anew{k} = char(a{k});
      elseif islogscalar(a(k))
        anew{k} = char(string(a{k}));
      elseif isnumscalar(a{k})
        anew{k} = num2str(a{k});
      else
        anew{k} = nan;
      end
    end
  elseif istabular(a)
    anew = array2cellstr(table2cell(a));
  else
    anew = {nan};    
  end
