function bool = isReal(a)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are real numbers
  % -------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
  end
  % check for symbolic functions
  if issymfun(a)
    a = formula(a);
  end
  %% compute the logical array
  if isnumeric(a)
    bool = false(size(a));
    for k = 1:numel(a)
      bool(k) = isreal(a(k));
    end
  else
    bool = sym.zeros(size(a));
    for k = 1:numel(a)
      bool(k) = in(a(k), 'real');
    end
  end
