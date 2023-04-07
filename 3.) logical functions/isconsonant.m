function bool = isconsonant(a)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are consonants
  % -------------------------
  narginchk(1,1);
  if ~isText(a)
    bool = false;
  elseif ischar(a)
    bool = ismember(lower(a), setdiff('a':'z', 'aeiou'));
  else  
    bool = ismember(lower(a), num2cell(setdiff('a':'z', 'aeiou')));
  end
