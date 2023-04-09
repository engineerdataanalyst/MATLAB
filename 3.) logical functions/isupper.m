function bool = isupper(a)
  % -----------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are upper case letters
  % -----------------------------
  narginchk(1,1);
  if ~isText(a)
    bool = false;
  elseif ischar(a)
    bool = ismember(a, 'A':'Z');
  else  
    bool = ismember(a, num2cell('A':'Z'));
  end
