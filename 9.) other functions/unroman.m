function num = unroman(numeral)
  % -------------------------------
  % - computes the numeric value
  %   of an array of roman numerals
  % -------------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    numeral {mustBeText};
  end
  % check the numeral
  if ~isstring(numeral)
    numeral = string(numeral);
  end
  %% compute the numeral list
  persistent numerals
  if isempty(numerals)
    numerals = roman(1:3999);
  end
  %% compute the numeric value of the roman numerals
  numeral = strtrim(numeral);
  num = nan(size(numeral));
  for k = 1:numel(numeral)
    % remove the '-' sign from the numerals
    if startsWith(numeral(k), '-')
      negative = true;
      numeral{k}(1) = [];
    else
      negative = false;
    end
    % compute the numeric value of the roman numerals
    ind = find(strcmpi(numeral(k), numerals), 1);
    if ~isempty(ind)
      num(k) = ind;
    end
    if negative
      num = -num;
    end
  end
