function [I fnew cp cp_norm] = surface_int(f, rfun, limits, varargin)
  % --------------------------------------------
  % - computes the surface integral of a
  %   scalar/vector field (f) over the surface
  %   parametrized by the vector function (rfun)
  % --------------------------------------------
  
  %% compute the default arguments
  narginchk(3,inf);
  options = varargin;
  if nargin < 4
    order = 1:2;    
  elseif nargin >= 4
    if isnumeric(varargin{1}) || issym(varargin{1})
      order = varargin{1};
      options = options(2:end);
    else
      order = [];
    end
    if isempty(order)
      order = 1:2;
    end
  end
  %% check the input arguments
  % check the integrating function
  narginchk(3,inf);
  if ~issymfunvector(f, 'CheckEmpty', true)
    error('''f'' must be a symbolic function of a non-empty vector');
  end
  if numArgs(f) ~= 3
    error('''f'' must have 3 function arguments');
  end
  % check the displacement function
  if ~issymfunvector(rfun, 'Len', 3)
    str = stack('''rfun'' must be a symbolic function', ...
                'of a vector of length 3');
    error(str);
  end
  if numArgs(rfun) ~= 2
    error('''rfun'' must have 2 function arguments');
  end
  % check the function lengths
  if ~isequallen(f, rfun) && ~isScalar(f)
    str = stack('the length of ''f'' must be the same as', ...
                'the length of ''rfun'', (if ''f'' is not a scalar)');
    error(str);
  end
  % check the integration limits
  if issymfun(limits)
    limits = formula(limits);
  end
  if ~isnummatrix(limits, 'Dim', 2) && ~issymmatrix(limits, 'Dim', 2)
    str = stack('''limits'' must be', ...
                'a numeric or symbolic 2x2 matrix');
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
  %% compute the surface integral data
  rfun_args = argnames(rfun);
  rfun_cell = array2cell(rfun);
  IAC = {'IgnoreAnalyticConstraints' true};
  fnew(rfun_args) = f(rfun_cell{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
  cp = cross(diff(rfun, rfun_args(1)), diff(rfun, rfun_args(2)));
  cp = simplify(simplifyFraction(cp), IAC{:});
  cp_norm = Norm(cp);
  cp_norm = simplify(cp_norm, IAC{:});
  %% compute the surface integral
  if isScalar(f)    
    integrand = fnew*cp_norm;
  else
    integrand = Dot(fnew, cp);
  end
  I = iter_int(integrand, limits, order, options{:});
