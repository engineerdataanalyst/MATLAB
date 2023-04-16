function expr = surface_areax(varargin)
  % -----------------------------
  % - computes the surface area
  %   of a symbolic expression by
  %   rotating about the x-axis
  % -----------------------------
  try
    s = parse_rev_args(varargin{:});
  catch Error
    throw(Error);
  end
  mode = s.mode;
  range = s.range;
  A = s.A;
  options = s.options;
  IAC = {'IgnoreAnalyticConstraints' true};
  switch mode
    case "cartesian"
      y = s.y;
      dy = s.dy;
      x = s.x;
      integrand = 2*sympi*abs(y-A).*sqrt(1+dy.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, x, range, options{:});
    case "polar"
      r = s.y;
      dr = s.dy;
      theta = s.x;
      y = r*sin(theta);
      integrand = 2*sympi*abs(y-A).*sqrt(r.^2+dr.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, theta, range, options{:});
    case "parametric"
      yt = s.yt;
      dxt = s.dxt;
      dyt = s.dyt;
      t = s.t;
      integrand = 2*sympi*(yt-A).*sqrt(dxt.^2+dyt.^2);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      expr = int(integrand, t, range, options{:});
  end
  if ~hasSymType(expr, 'int')
    expr = simplify(expr, IAC{:});
  end
