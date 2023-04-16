function [f g] = fake_quotient(g, x, options)
  % --------------------------------
  % - given a function (g),
  %   computes a second function (f)
  %   in the fake quotient rule
  % - (f/g)' == f'/g'
  % --------------------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    g sym;
    x sym = default_var(g);
    options.IgnoreAnalyticConstraints;
    options.IgnoreSpecialCases;
    options.PrincipalValue;
    options.Hold;
  end
  % check the argument dimensions
  if ~compatible_dims(g, x)
    error('input arguments must have compatible dimensions');
  end
  % check the integraiton variable
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  end
  % check the integration options
  options = namedargs2cell(options);
  %% compute the fake product rule function
  IAC = {'IgnoreAnalyticConstraints' true};
  dg = diff(g, x);
  f = simplify(dg.^2./(dg.*g-g.^2), IAC{:});
  f = exp(int(f, options{:}));
end
% =
function x = default_var(a)
  % ----------------------------------
  % - helper function for determining
  %   the default integration variable
  % ----------------------------------
  if ~isallsymnum(a)
    x = symvar(a, 1);
  else
    x = sym('x');
  end
end
% =
