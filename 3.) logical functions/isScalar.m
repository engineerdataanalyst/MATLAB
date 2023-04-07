function bool = isScalar(a, classname)
  % --------------------------
  % - returns true if an array
  %   is a scalar
  %   with a specific type
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector} = 'classname';
  end
  %% check the array
  if nargin == 1
    if issymfun(a)
      bool = isscalar(formula(a));
    else
      bool = isscalar(a);
    end
  else
    func = @(arg) isa(a, arg);
    classname = unique(string(classname), 'stable');
    bool = any(arrayfun(func, classname)) && isScalar(a);
  end
