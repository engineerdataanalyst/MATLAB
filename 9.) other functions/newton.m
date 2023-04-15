function [y iter] = newton(f, x0, tol)
  % ------------------------------
  % - finds the root of a function
  %   using Newton's Method
  % ------------------------------

  %% check input arguments
  if nargin == 2
    tol = 1e-6;
  end
  if ~issymfun(f) && ~issym(f)
    str = stack('first argument must be a', ...
                'symbolic function or symbolic variable');
    error(str);
  end
  args = symvar(f);
  if length(args) ~= 1
    error('first argument must have only one variable');
  end
  if ~issymfun(f)
    f(args) = f;
  end
  if ~isnumeric(x0)
    error('second argument must be numeric');
  end
  %% apply newton-raphson method
  df = diff(f);
  old = x0;    
  err = 2*tol;
  iter = 0;  
  while err > tol
    new = old-f(old)/df(old);
    old = new;
    err = f(new);
    iter = iter+1;
  end
  y = new;
