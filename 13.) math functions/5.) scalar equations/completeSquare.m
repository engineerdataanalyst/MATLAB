function answer = completeSquare(a, x, options)
  % ---------------------------
  % - completes the square of a
  %   quadratic expression
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    x sym = default_var(a);
    options.Factor (1,1) logical = false;
  end
  % check the argument dimensions
  if ~compatible_dims(a, x)
    error('input arguments must have compatible dimensions');
  end
  [~, x] = scalar_expand(a, x);
  % check the quadratic functions
  if ~all(degree(a, x) == 2, 'all')
    error('''a'' must contain second order polynomial expressions');
  elseif issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end      
  % check the quadratic variables
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  elseif issymfun(x)
    x = formula(x);
  end
  % check the factoring option
  Factor = options.Factor;
  %% complete the square
  answer = sym.zeros(size(a));
  for k = 1:numel(a)
    coeff = num2cell(coeffs(a(k), x(k), 'All'));
    [A B C] = deal(coeff{:});
    H = B/(2*A);
    if Factor
      K = (4*A*C-B^2)/(4*A^2);
      answer(k) = A*((x(k)+H)^2+K);
    else
      K = (4*A*C-B^2)/(4*A);
      answer(k) = A*(x(k)+H)^2+K;
    end
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    answer(args) = answer;
  end
end
% =
function x = default_var(f)
  % ---------------------------------
  % - helper function for determining
  %   the default polynomial variable
  % ---------------------------------
  if ~isallsymnum(f)
    x = symvar(f, 1);
  else
    x = sym('x');
  end
end
% =
