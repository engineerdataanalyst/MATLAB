function bool = isroman(str)
  persistent list;
  if isempty(list)
    list = roman(-3999:3999);
  end
  if ~isTextArray(str, ["char" "string" "cell of char"])
    bool = false;
  else
    str = cellstr(str);
    bool = false(size(str));
    for k = 1:numel(str)
      bool(k) = ismember(str{k}, list);
    end
  end
