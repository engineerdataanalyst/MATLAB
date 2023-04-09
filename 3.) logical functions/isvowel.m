function bool = isvowel(a)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are vowels
  % -------------------------
  narginchk(1,1);
  if ~isText(a)
    bool = false;
  elseif ischar(a)
    bool = ismember(lower(a), 'aeiou');
  else  
    bool = ismember(lower(a), num2cell('aeiou'));
  end
