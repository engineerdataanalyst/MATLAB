function [I fnew Jd Jm] = cylindrical_int(f, limits, varargin)
  % -----------------------------------
  % - computes the triple integral
  %   of a function (f) over the region
  %   bounded by (limits)
  %   using cylindrical coordinates
  % -----------------------------------

  %% compute the default arguments
  narginchk(2,inf);
  options = varargin;
  if nargin < 3
    order = 1:3;
    cylindrical_vars = [sym('theta') sym('r') sym('z')];
  elseif nargin >= 3
    if isnumeric(varargin{1}) || issym(varargin{1})
      order = varargin{1};
      options = options(2:end);
    else
      order = [];
    end
    if (nargin >= 4) && issym(varargin{2})
      cylindrical_vars = varargin{2};
      options = options(2:end);
    else
      cylindrical_vars = [];
    end
    if isempty(order)
      order = 1:3;
    end
    if isempty(cylindrical_vars)
      cylindrical_vars = [sym('theta') sym('r') sym('z')];
    end
  end
  %% check the input arguments
  % check the symbolic function
  if ~issymfun(f)
    error('''f'' must be a symbolic function');
  end
  if numArgs(f) ~= 3
    error('''f'' must have 3 input arguments');
  end
  f_args = argnames(f);
  % check the limits of integration
  if ~isnummatrix(limits, 'Dim', [3 2]) && ...
     ~issymmatrix(limits, 'Dim', [3 2])
    str = stack('''limits'' must be', ...
                'a numeric or symbolic 3x2 array');
    error(str);
  end
  % check the order of integration
  if ~isintvector(order, 'Len', 3, 'Type', 'positive') || ...
     ~isperm(order(:).', 1:3)
    str = stack('''order'' must be', ...
                'a numeric vector', ...
                'containing a permuation', ...
                'of the numbers 1-3');
    error(str);
  end
  % check the cylindrical variables
  if ~issymvarvector(cylindrical_vars, 'Len', 3)
    str = stack('''cylindrical_vars'' must be', ...
                'a symbolic vector of length 3', ...
                'containing symbolic variables');
    error(str);
  end
  bool = order ~= 3;
  if any(ismember(f_args(bool), cylindrical_vars(bool)))
    str = stack('input arguments to ''f''', ...
                'must not contain any variables', ...
                'in ''cylindrical_vars''');
    error(str);
  end
  %% compute the cylindrical variables
  cylindrical_vars = formula(cylindrical_vars);
  ordered_cylindrical_vars = cylindrical_vars(order);
  theta = ordered_cylindrical_vars(order == 1);
  r = ordered_cylindrical_vars(order == 2);
  z = ordered_cylindrical_vars(order == 3);
  %% compute the original variables
  xc = r*cos(theta);
  yc = r*sin(theta);
  zc = z;
  original_vars = {xc yc zc};
  %% compute the triple integral data
  IAC = {'IgnoreAnalyticConstraints' true};
  fnew(cylindrical_vars) = f(original_vars{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
  Jd(cylindrical_vars) = r;
  Jm(cylindrical_vars) = jacobian([xc yc zc], [r theta z]);
  %% compute the triple integral
  integrand = fnew*Jd;
  I = iter_int(integrand, limits, order, options{:});
