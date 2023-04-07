function bool = isoddfun(a, x)
  % ------------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of a symbolic array
  %   that are odd functions
  % ------------------------------

  %% check the input arguments
  % check the argument classes
  arguments
    a;
    x sym = default_var(a);
  end
  % check the argument dimensions
  if ~compatible_dims(a, x)
    error('input arguments must have compatible dimensions');
  end
  [~, x] = scalar_expand(a, x);
  % check the symbolic array
  if issymfun(a)
    a = formula(a);
  end
  % check the symbolic variables
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  elseif issymfun(x)
    x = formula(x);
  end
  %% comopute the logical array
  if (~isnumeric(a) && ~issym(a)) || isEmpty(a)
    bool = false;
  else
    bool = false(size(a));
    for k = 1:numel(a)
      a_negx = subs(a(k), x(k), -x(k));
      bool(k) = isAlways(a_negx == -a(k), 'Unknown', 'false');
    end
  end
end
% =
function x = default_var(a)
  % ---------------------------------
  % - helper function for determining
  %   the default polynomial variable
  % ---------------------------------
  if issym(a) && ~isallsymnum(a)
    x = symvar(a, 1);
  else
    x = sym('x');
  end
end
% =
