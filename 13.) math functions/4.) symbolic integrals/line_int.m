function [I fnew dr dr_norm] = line_int(f, rfun, limits, varargin)
  % --------------------------------------------
  % - computes the line integral of a
  %   scalar/vector field (f) over the curve
  %   parametrized by the vector function (rfun)
  % --------------------------------------------
  
  %% check the input arguments
  % check the integrating and displacement functions
  narginchk(3,inf);
  if ~issymfunvector(f, 'CheckEmpty', true) || ...
     ~issymfunvector(rfun, 'CheckEmpty', true)
    str = stack('''f'' and ''rfun'' must be', ...
                'symbolic functions of non-empty vectors');
    error(str);
  end
  % check the integrating and displacement function arguments
  if ~isequallen(argnames(f), rfun)
    str = stack('the number of function arguments to ''f''', ...
                'must be the same as the length of ''rfun''');
    error(str);
  end
  % check the integrating and displacement function lengths
  if ~isequallen(f, rfun) && ~issymfunscalar(f)
    str = stack('the length of ''f'' must be the same as', ...
                'the length of ''rfun'', (if ''f'' is not a scalar)');
    error(str);
  end
  % check the number of displacement function arguments
  if numArgs(rfun) ~= 1
    error('''rfun'' must have one function argument');
  end
  % check the integration limits
  if ~isnumvector(limits, 'Len', 2) && ~issymvector(limits, 'Len', 2)
    str = stack('''limits'' must be', ...
                'a numeric or symbolic vector of length 2');
    error(str);
  end
  %% compute the line integral data
  t = argnames(rfun);
  r_cell = array2cell(rfun);
  IAC = {'IgnoreAnalyticConstraints' true};
  fnew(t) = f(r_cell{:});
  fnew = simplify(simplifyFraction(fnew), IAC{:});
  dr = diff(rfun, t);
  dr = simplify(simplifyFraction(dr), IAC{:});
  dr_norm = Norm(dr);
  dr_norm = simplify(simplifyFraction(dr_norm), IAC{:});
  %% compute the line integral
  if isScalar(f)
    integrand = fnew*dr_norm;
  else  
    integrand = Dot(fnew, dr);
  end  
  I = int(integrand, t, limits, varargin{:});
  I = simplify(I, IAC{:});
