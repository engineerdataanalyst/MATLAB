function num = Numel(a)
  % ----------------------------------------------
  % - a slight variation of the numel function
  % - for symbolic functions, will return
  %   the number of elements of its body
  % - since symbolic functions are always scalars,
  %   the regular numel function will always
  %   return 1 for symbolic functions
  % ----------------------------------------------
  narginchk(1,1);  
  if issymfun(a)
    num = numel(formula(a));
  else
    num = numel(a);
  end
