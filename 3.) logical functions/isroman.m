function bool = isroman(str)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are roman numerals
  % -------------------------
  narginchk(1,1);
  if ~isTextArray(str, ["char" "string" "cell of char"])
    bool = false;
  else
    bool = ~isnan(unroman(str));
  end
