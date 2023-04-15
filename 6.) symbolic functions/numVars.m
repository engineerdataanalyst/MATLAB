function num = numVars(a)
  % -----------------------
  % - returns the number of
  %   variables in a
  %   symbolic expression
  % -----------------------
  
  %% check the input argument
  arguments
    a {mustBeA(a, 'sym')};
  end
  %% compute the number of symbolic function arguments
  num = length(symvar(a));
