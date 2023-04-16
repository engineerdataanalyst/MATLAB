function [I fnew Jd Jm] = polar_int(f, limits, varargin)
  % -----------------------------------
  % - computes the double integral
  %   of a function (f) over the region
  %   bounded by (limits)
  %   using polar coordinates
  % -----------------------------------

  %% compute the default arguments
  narginchk(2,inf);
  options = varargin;
  if nargin < 3
    order = 1:2;
    polar_vars = [sym('theta') sym('r')];
  elseif nargin >= 3
    if isnumeric(varargin{1}) || issym(varargin{1})
      order = varargin{1};
      options = options(2:end);
    else
      order = [];
    end
    if (nargin >= 4) && issym(varargin{2})
      polar_vars = varargin{2};
      options = options(2:end);
    else
      polar_vars = [];
    end
    if isempty(order)
      order = 1:2;
    end
    if isempty(polar_vars)
      polar_vars = [sym('theta') sym('r')];
    end
  end
  %% check the input arguments
  % check the symbolic function
  if ~issymfun(f)
    error('''f'' must be a symbolic function');
  end
  if numArgs(f) ~= 2
    error('''f'' must have 2 input arguments');
  end
  % check the limits of integration
  if ~isnummatrix(limits, 'Dim', 2) && ~issymmatrix(limits, 'Dim', 2)
    str = stack('''limits'' must be', ...
                'a numeric or symbolic 2x2 array');
    error(str);
  end
  % check the order of integration
  if ~isintvector(order, 'Len', 2, 'Type', 'positive') || ...
     ~isperm(order(:).', 1:2)
    str = stack('''order'' must be', ...
                'a numeric vector', ...
                'containing a permuation', ...
                'of the numbers 1-2');
    error(str);
  end
  % check the polar variables
  if ~issymvarvector(polar_vars, 'Len', 2)
    str = stack('''polar_vars'' must be', ...
                'a symbolic vector of length 2', ...
                'containing symbolic variables');
    error(str);
  end
  if any(ismember(argnames(f), polar_vars))
    str = stack('input arguments to ''f''', ...
                'must not contain any variables', ...
                'in ''polar_vars''');
    error(str);
  end
  %% compute the polar variables
  polar_vars = formula(polar_vars);
  ordered_polar_vars = polar_vars(order);
  theta = ordered_polar_vars(order == 1);
  r = ordered_polar_vars(order == 2);
  %% compute the original variables
  xp = r*cos(theta);
  yp = r*sin(theta);
  original_vars = {xp yp};  
  %% compute the double integral data
  IAC = {'IgnoreAnalyticConstraints' true};
  fnew(polar_vars) = f(original_vars{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
  Jd(polar_vars) = r;
  Jm(polar_vars) = jacobian([xp yp], [r theta]);
  %% compute the double integral
  integrand = fnew*Jd;
  I = iter_int(integrand, limits, order, options{:});
