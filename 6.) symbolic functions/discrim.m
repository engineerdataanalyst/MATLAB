function answer = discrim(a, x)
  % ----------------------------
  % - the MuPAd discrim function
  % ----------------------------
  
  %% check the input argument
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
  % check the symbolic array array
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  % check the polynomial variables
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  elseif issymfun(x)
    x = formula(x);
  end
  %% compute the polynomial discriminant
  IAC = {'IgnoreAnalyticConstraints' true};
  answer = sym.nan(size(a));
  for k = 1:numel(a)
    if ispoly(a(k))
      deg = degree(a(k), x(k));
      coeff = coeffs(a(k), x(k), 'All');
      neg1 = (-1)^(deg*(deg-1)/2);
      da = diff(a(k), x(k));
      resultant = feval(symengine, 'polylib::resultant', a(k), da, x(k));
      answer(k) = simplify(neg1*resultant/coeff(1), IAC{:});
    end
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    answer(args) = answer;
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
