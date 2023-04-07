function bool = isgreek(a)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are greek letters
  % -------------------------
  narginchk(1,1);
  if ~isText(a)
    bool = false;
  elseif ischar(a)
    bool = ismember(a, char(913:969));
  else  
    bool = ismember(a, num2cell(char(913:969)));
  end
