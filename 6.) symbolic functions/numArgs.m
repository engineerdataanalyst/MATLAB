function num = numArgs(a)
  % -----------------------
  % - returns the number of
  %   input arguments to a 
  %   symbolic function
  % -----------------------
  
  %% check the input argument
  arguments
    a {mustBeA(a, 'sym')};
  end
  %% compute the number of symbolic function arguments
  num = length(argnames(a));
