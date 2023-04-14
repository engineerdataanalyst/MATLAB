function num = Ndims(a)
  % ------------------------------------------
  % - a slight variation of the ndims function
  % - for symbolic functions, will return
  %   the number of dimensions of its body
  % - since symbolic are always scalars, 
  %   the regular ndims function will always
  %   return 2 for symbolic functions
  % ------------------------------------------
  narginchk(1,1);  
  if issymfun(a)
    num = ndims(formula(a));
  else
    num = ndims(a);
  end
