function expr = arc_length(varargin)
  % --------------------------
  % - computes the arc length
  %   of a symbolic expression
  % --------------------------
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
      dy = s.dy;
      x = s.x;
      integrand = sqrt(1+dy.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, x, range, options{:});
    case "polar"
      r = s.y;
      dr = s.dy;
      theta = s.x;
      integrand = sqrt(r.^2+dr.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, theta, range, options{:});
    case "parametric"
      dxt = s.dxt;
      dyt = s.dyt;
      t = s.t;
      integrand = sqrt(dxt.^2+dyt.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, t, range, options{:});
  end
  if ~hasSymType(expr, 'int')
    expr = simplify(expr, IAC{:});
  end
