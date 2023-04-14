function answer = degree(a, x)
  % ---------------------------
  % - the MuPAD degree function
  % ---------------------------
  
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
  %% compute the polynomial degrees
  answer = nan(size(a));
  for k = 1:numel(a)
    type = feval(symengine, 'Type::PolyExpr', x(k));
    if feval(symengine, 'testtype', a(k), type)
      answer(k) = feval(symengine, 'degree', a(k), x(k));
    end
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
