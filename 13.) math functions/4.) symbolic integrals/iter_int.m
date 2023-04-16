function I = iter_int(f, limits, varargin)
  % -------------------------------------
  % - computes the iterated integral
  %   of a symbolic function (f)
  %   with limits of integration (limits)
  % -------------------------------------
  
  %% compute the default arguments
  narginchk(2,inf);
  options = varargin;
  if nargin < 3
    order = 1:numArgs(f);
  elseif nargin >= 3
    if isnumeric(varargin{1}) || issym(varargin{1})
      order = varargin{1};
      options = options(2:end);
    else
      order = [];
    end
    if isempty(order) && issymfun(f)
      order = 1:numArgs(f);
    end
  end
  %% check the input arguments
  % check the integrating function
  narginchk(2,inf);
  if ~issymfun(f)
    error('''f'' must be a symbolic function');
  end
  % check the integration limits
  if issymfun(limits)
    limits = formula(limits);
  end
  if (~isnummatrix(limits) && ~issymmatrix(limits)) || ...
     size(limits, 2) ~= 2
    str = stack('''limits'' must be', ...
                'a numeric or symbolic 2-D array', ...
                'with 2 columns');
    error(str);
  end
  if numArgs(f) ~= size(limits, 1)
    str = stack('the number of arguments to ''f''', ...
                'must be the same as', ...
                'the number of rows on ''limits''');
    error(str);
  end
  % check the order of integration
  if ~isintvector(order, 'Len', numArgs(f), 'Type', 'positive') || ...
     ~isperm(order(:).', 1:numArgs(f))
    str = stack('''order'' must be', ...
                'a numeric vector', ...
                'containing a permuation', ...
                'of the numbers 1-numArgs(f)');
    error(str);
  end
  %% compute the integration variables
  vars = argnames(f);
  vars = vars(order);
  %% compute the iterated integral
  num_vars = length(vars);
  IAC = {'IgnoreAnalyticConstraints' true};
  for k = num_vars:-1:1
    if k == num_vars
      integrand = f;
    else
      integrand = I;
    end
    if ~hasSymType(integrand, 'int')
      integrand = simplify(simplifyFraction(integrand), IAC{:});
    end
    I = int(integrand, vars(k), limits(k,:), options{:});
  end
  if ~hasSymType(I, 'int')
    I = simplify(simplifyFraction(I), IAC{:});
  end
