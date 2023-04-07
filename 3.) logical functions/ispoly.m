function bool = ispoly(a, x)
  % -------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are symbolic
  %   polynomial expressions
  % ------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    x sym = default_var(a);
  end
  % check the argument dimensions
  if ~compatible_dims(a, x)
    error('input arguments must have compatible dimensions');
  end
  [~, x] = scalar_expand(a, x);
  % check the polynomial array
  a = formula(a);
  % check the polynomial variables
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  elseif issymfun(x)
    x = formula(x);
  end
  %% compute the logical array
  bool = false(size(a));
  for k = 1:numel(a)
    type = feval(symengine, 'Type::PolyExpr', x(k));
    bool(k) = feval(symengine, 'testtype', a(k), type);
  end
end
% =
function x = default_var(a)
  % ---------------------------------
  % - helper function for determining
  %   the default polynomial variable
  % ---------------------------------
  if ~isallsymnum(a)
    x = symvar(a, 1);
  else
    x = sym('x');
  end
end
% =
