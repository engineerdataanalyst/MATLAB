function expr = sym_area(varargin)
  % -----------------------------------
  % - computes the area under the curve
  %   of a symbolic expression  
  % -----------------------------------
  try
    s = parse_int_args(varargin{:});
  catch Error
    throw(Error);
  end
  mode = s.mode;
  range = s.range;
  options = s.options;
  IAC = {'IgnoreAnalyticConstraints' true};
  switch mode
    case "cartesian"
      y = s.y;
      x = s.x;
      integrand = y;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, x, range, options{:});
    case "polar"
      r = s.y;
      theta = s.x;
      integrand = r.^2/2;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, theta, range, options{:});
    case "parametric"
      yt = s.yt;
      t = s.t;
      dxt = s.dxt;
      integrand = yt.*dxt;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, t, range, options{:});   
  end
  if ~hasSymType(expr, 'int')
    expr = simplify(expr, IAC{:});
  end
