function varargout = lagrange(f, g, num, varargin)
  % ----------------------------
  % - solves for the constrained
  %   minimum and maximum values
  %   using lagrange multipliers
  % ----------------------------
  
  %% compute the default argument
  if nargin < 3 || (nargin > 3 && isempty(num))
    num = 0;
  end
  %% check the input arguments
  if ~isnumscalar(f) && ~issymscalar(f)
    str = stack('first argument must be', ...
                'a numeric or symbolic scalar');
    error(str);
  end
  if (~isnumvector(g, 'CheckEmpty', true) && ...
      ~issymvector(g, 'CheckEmpty', true)) || ...
     (~isnumvector(num, 'CheckEmpty', true) && ...
      ~issymvector(num, 'CheckEmpty', true)) || ...
     (~isequallen(g, num) && ~isscalar(g) && ~isscalar(num))
    str = stack('second and third arguments must be', ...
                'non-empty numeric or symbolic vectors', ...
                'with the same lengths');
    error(str);
  end
  func = @(arg) isTextScalar(arg, 'CheckEmptyText', true);
  symvarvectors = cellfun(@issymvarvector, varargin);
  TextScalars = cellfun(func, varargin);
  logscalars = cellfun(@islogscalar, varargin);
  if ~all(symvarvectors | TextScalars | logscalars)
    str = stack('fourth argument and all others that follow', ...
                'must be one of these types:', ...
                '---------------------------', ...
                '1.) symbolic vector of variables', ...
                '2.) non-empty strings', ...
                '3.) logical scalars');
    error(str);
  end
  %% make any necessary changes to the input arguments
  % fix f
  if isnumeric(f)
    f = sym(f);
  elseif issymfun(f)
    use_argnames = true;
    args = argnames(f);
    f = formula(f);
  else
    use_argnames = false;
  end
  % fix g
  if isnumeric(g)
    g = sym(g);
  elseif issymfun(g)
    g = formula(g);
  end
  if ~iscolumn(g)
    g = g.';
  end
  % fix num
  if isnumeric(num)
    num = sym(num);
  elseif issymfun(num)
    num = formula(num);
  end  
  if ~iscolumn(num)
    num = num.';
  end
  %% compute the variables
  vars = sym(convert2row(varargin(symvarvectors)));
  if isempty(vars)
    if use_argnames
      vars = args;
    else
      vars = symvar([f; g]);
    end
  end
  if any(ismember(symvar(num), vars))
    str = stack('third argument must not contain', ...
                'any of the variables to solve for');
    error(str);
  end
  %% compute lambda
  Vars2Exclude = symvar([f; g; num; vars.']);
  num_constraints = max(length(g),length(num));
  if num_constraints == 1
    lambda = sym('lambda');
  else
    lambda = sym('lambda', [num_constraints 1]);
  end
  lambda_loc = ismember(lambda.', Vars2Exclude);
  for k = find(lambda_loc)
    [lambda(k) Vars2Exclude] = randsym('Vars2Exclude', Vars2Exclude);
  end
  %% compute the equations
  if isscalar(g) && ~isscalar(num)
    g_cell = num2cell(repmat(g, size(num)));
  else
    g_cell = num2cell(g);
  end
  vars_cell = repmat({vars}, size(g_cell));
  A = cellfun(@gradient, g_cell, vars_cell, 'UniformOutput', false);
  eqn = [gradient(f, vars) == [A{:}]*lambda; g == num];
  %% compute the lagrange multipler solution
  options = varargin(~symvarvectors);
  [varargout{1:max(nargout, 1)}] = solve(eqn, [vars lambda.'], options{:});
