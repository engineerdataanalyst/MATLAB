function Ixy = product_of_inertia(varargin)
  % ---------------------------------
  % - computes the product of inertia
  %   about the x and y axes
  %   for a symbolic expression
  % ---------------------------------
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
      integrand = x*y.^2/2;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      Ixy = int(integrand, x, range, options{:});
    case "polar"
      r = s.y;
      theta = s.x;
      integrand = r.^4/4*sin(theta)*cos(theta);
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      Ixy = int(integrand, theta, range, options{:});
    case "parametric"
      xt = s.xt;
      yt = s.yt;
      dxt = s.dxt;
      t = s.t;
      integrand = xt.*yt.^2/2.*dxt;
      integrand = simplify(simplifyFraction(integrand), IAC{:});
      Ixy = int(integrand, t, range, options{:});
  end
  if ~hasSymType(Ixy, 'int')
    Ixy = simplify(Ixy, IAC{:});
  end
