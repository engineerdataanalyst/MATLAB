function expr = volume_shell(varargin)
  % ------------------------------------
  % - computes the volume of
  %   a symbolic expression by
  %   using the cylindrical shell method
  % ------------------------------------
  try
    s = parse_rev_args(varargin{:});
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
      A = s.A;
      integrand = 2*sympi*abs(x-A).*y;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, x, range, options{:});
    case "polar"
      r = s.y;
      theta = s.x;
      A = s.A;
      integrand = 2*sympi*abs(r.^3/3*cos(theta)-A.*r.^2/2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, theta, range, options{:});
    case "parametric"
      xt = s.xt;
      yt = s.yt;
      dxt = s.dxt;
      t = s.t;
      A = s.A;
      integrand = 2*sympi*(xt-A).*yt.*dxt;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, t, range, options{:});
  end
  if ~hasSymType(expr, 'int')
    expr = simplify(expr, IAC{:});
  end
