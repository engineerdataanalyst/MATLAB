function bool = isEmpty(a)
  % --------------------------------------------
  % - a slight variation of the isempty function
  % - for symbolic functions, will return true
  %   if its body is empty
  % - since symbolic are always scalars,
  %   the regular isempty function will always
  %   return false for symbolic functions
  % --------------------------------------------
  narginchk(1,1);
  if issymfun(a)
    bool = isempty(formula(a));
  else
    bool = isempty(a);
  end
