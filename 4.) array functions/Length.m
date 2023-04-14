function num = Length(a)
  % ----------------------------------------------
  % - a slight variation of the length function
  % - for symbolic functions, will return
  %   the length of its body
  % - since symbolic functions are always scalars,
  %   the regular length function will always
  %   return 1 for symbolic functions
  % ----------------------------------------------
  narginchk(1,1);  
  if issymfun(a)
    num = length(formula(a));
  else
    num = length(a);
  end
