function num = Height(a)
  % -------------------------------------------
  % - a slight variation of the height function
  % - for symbolic functions, will return
  %   the number of elements of its body
  % - since symbolic are always scalars,
  %   the regular height function will always
  %   return 1 for symbolic functions
  % -------------------------------------------
  narginchk(1,1);  
  if issymfun(a)
    num = height(formula(a));
  else
    num = height(a);
  end
