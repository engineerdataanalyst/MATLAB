function a = arraysubs(a, old, new)
  % -------------------------
  % - calls the subs function
  %   on each element of a
  %   symbolic array
  % -------------------------
  
  %% check the input arguments
  arguments
    a sym;
    old;
    new;
  end
  %% call the subs function
  try
    func = @(A) subs(A, old, new);
    args = argnames(a);
    a = arrayfun(func, formula(a));
    if ~isempty(args)
      a(args) = a;
    end
  catch Error
    throw(Error);
  end
