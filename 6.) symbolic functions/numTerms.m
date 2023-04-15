function num = numTerms(a)
  % -----------------------
  % - returns the number of
  %   terms in a
  %   symbolic expression
  % -----------------------
  
  %% check the input argument
  arguments
    a {mustBeA(a, 'sym')};
  end
  %% compute the number of terms
  if isSymType(a, 'plus')
    num = length(children(a));
  else
    num = 1;
  end
