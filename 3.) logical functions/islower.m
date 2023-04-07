function bool = islower(a)
  % -----------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are lower case letters
  % -----------------------------
  narginchk(1,1);
  if ~isText(a)
    bool = false;
  elseif ischar(a)
    bool = ismember(a, 'a':'z');
  else  
    bool = ismember(a, num2cell('a':'z'));
  end
