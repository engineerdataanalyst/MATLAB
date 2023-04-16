function [I fnew Jd Jm] = spherical_int(f, limits, varargin)
  % -----------------------------------
  % - computes the triple integral
  %   of a function (f) over the region
  %   bounded by (limits) 
  %   using spherical coordinates
  % -----------------------------------

  %% compute the default arguments
  narginchk(2,inf);
  options = varargin;
  if nargin < 3
    order = 1:3;
    spherical_vars = [sym('theta') sym('phi') sym('rho')];
  elseif nargin >= 3
    if isnumeric(varargin{1}) || issym(varargin{1})
      order = varargin{1};
      options = options(2:end);
    else
      order = [];
    end
    if (nargin >= 4) && issym(varargin{2})
      spherical_vars = varargin{2};
      options = options(2:end);
    else
      spherical_vars = [];
    end
    if isempty(order)
      order = 1:3;
    end
    if isempty(spherical_vars)
      spherical_vars = [sym('theta') sym('phi') sym('rho')];
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
  % check the spherical variables
  if ~issymvarvector(spherical_vars, 'Len', 3)
    str = stack('''spherical_vars'' must be', ...
                'a symbolic vector of length 3', ...
                'containing symbolic variables');
    error(str);
  end
  if any(ismember(argnames(f), spherical_vars))
    str = stack('input arguments to ''f''', ...
                'must not contain any variables', ...
                'in ''spherical_vars''');
    error(str);
  end
  %% compute the spherical variables
  spherical_vars = formula(spherical_vars);
  ordered_spherical_vars = spherical_vars(order);
  theta = ordered_spherical_vars(order == 1);
  phi = ordered_spherical_vars(order == 2);
  rho = ordered_spherical_vars(order == 3);
  %% compute the original variables
  xs = rho*sin(phi)*cos(theta);
  ys = rho*sin(phi)*sin(theta);
  zs = rho*cos(phi);
  original_vars = {xs ys zs};
  %% compute the triple integral data
  IAC = {'IgnoreAnalyticConstraints' true};
  fnew(spherical_vars) = f(original_vars{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
  Jd(spherical_vars) = rho^2*sin(phi);
  Jm(spherical_vars) = jacobian([xs ys zs], [rho phi theta]);
  %% compute the triple integral
  integrand = fnew*Jd;
  I = iter_int(integrand, limits, order, options{:});
