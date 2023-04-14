function f = Str2sym(str)
  % --------------------------------------------
  % - converts a string to a symbolic array
  %  (fixes the cases of variables E, I, and Re)
  % --------------------------------------------
  
  %% check the input argument
  arguments
    str {mustBeText};
  end
  %% fix the string
  str = fix_vars(str);
  str = fix_in(str);
  str = fix_int(str);
  str = fix_symsum(str);
  str = fix_symprod(str);
  str = fix_symunit(str);
  str = fix_piecewise(str);
  str = fix_matrix(str);
  %% convert the string to symbolic
  func = @(arg) evalin(symengine, arg);
  if ischar(str)
    f = func(str);
  else
    f = sym(cellfun(func, str, 'UniformOutput', false));
  end
