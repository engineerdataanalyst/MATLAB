function [scale coeff] = scalar_parts(a)
  % ----------------------------
  % - breaks apart an array into
  %   its scalar multiple parts
  % ----------------------------
  
  %% check the input argument
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
  end
  %% empty arrays
  if isempty(a)
    [scale coeff] = deal(a);
    return;
  end
  %% numeric or symbolic arrays with all numbers or piecewise expressions
  if isnumeric(a) || isallsymnum(a) || any(ispiecewise(a), 'all')
    if isnumeric(a)
      scale = ones(1, 'like', a);
    elseif issymfun(a)
      scale(argnames(a)) = sym(1);
    else
      scale = sym(1);
    end
    coeff = a;
    return;
  end
  %% general case
  % temporarily convert symbolic functions to syms
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  % compute the scale and coefficients
  loc = ~isAlways(a == 0, 'Unknown', 'false') & isfinite(a);
  if ~any(loc)
    error('the assumptions do not allow any non-zero scales');
  end
  scale_factors = a(loc);
  scale_factors = factor(scale_factors(1));
  scale = prod(scale_factors(~issymnum(scale_factors)));
  coeff = simplify(a/scale, 'IgnoreAnalyticConstraints', true);
  % convert back to symbolic function if necessary
  if convert2symfun
    scale(args) = scale;
    coeff(args) = coeff;
  end
