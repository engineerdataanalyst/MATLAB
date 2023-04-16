function I = maz_int(Amaz, Bmaz, x, options)
  % --------------------------------
  % - computes the Maz identity
  %   integral transformation
  %   of the functions A(x) and B(x)
  % --------------------------------

  %% check the input arguments
  % check the argument classes
  arguments
    Amaz sym;
    Bmaz sym;
    x sym = default_var(Amaz, Bmaz);
    options.IgnoreAnalyticConstraints;
    options.IgnoreSpecialCases;
    options.PrincipalValue;
    options.Hold;
  end
  % check the argument dimensions
  options = Namedargs2cell(options);
  if ~compatible_dims(Amaz, Bmaz, x, options{2:2:end})
    error('input arguments must have compatible dimensions');
  end
  [Amaz Bmaz x options{:}] = scalar_expand(Amaz, Bmaz, x, options{:});
  % check the integration variable
  if ~issymvararray(x)
    error('''x'' must be an array of symbolic variables');
  end
  % check for invalid function arguments
  if ~isequalargnames(Amaz, Bmaz)
    error(message('symbolic:symfun:InputMatch'));
  end
  %% compute the maz integral transform
  func = @(A, B, x) laplace(A, x, x)*ilaplace(B, x, x);
  func = @(A, B, x, varargin) int(func(A, B, x), x, 0, inf, varargin{:});
  I = arrayfun(func, formula(Amaz), formula(Bmaz), formula(x), options{:});
  %% convert to symbolic function if necessary
  if issymfun(Amaz)
    args = setdiff(argnames(Amaz), x, 'stable');
  elseif issymfun(Bmaz)
    args = setdiff(argnames(Bmaz), x, 'stable');
  else
    args = [];
  end
  if ~isempty(args)
    I(args) = I;
  end
end
% =
function x = default_var(A, B)
  % ----------------------------------
  % - helper function for determining
  %   the default integration variable
  % ----------------------------------
  if ~isallsymnum(A)
    x = symvar(A, 1);
  elseif ~isallsymnum(B)
    x = symvar(B, 1);
  else
    x = sym('x');
  end
end
% =
