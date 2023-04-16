function [Ix Iy Iz] = moment_of_inertia(varargin)
  % ---------------------------------
  % - computes the moment of inertias
  %   about the x, y, and z axes
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
      integrandx = y.^3/3;
      integrandy = x^2*y;
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Ix = int(integrandx, x, range, options{:});
      Iy = int(integrandy, x, range, options{:});
    case "polar"
      r = s.y;
      theta = s.x;
      integrandx = r.^4/4*sin(theta)^2;
      integrandy = r.^4/4*cos(theta)^2;
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Ix = int(integrandx, theta, range, options{:});
      Iy = int(integrandy, theta, range, options{:});
    case "parametric"
      xt = s.xt;
      yt = s.yt;
      dxt = s.dxt;
      t = s.t;
      integrandx = yt.^3/3.*dxt;
      integrandy = xt.^2.*yt.*dxt;
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Ix = int(integrandx, t, range, options{:});
      Iy = int(integrandy, t, range, options{:});
  end
  Iz = Ix+Iy;
  if ~hasSymType(Ix, 'int')
    Ix = simplify(Ix, IAC{:});
    Iy = simplify(Iy, IAC{:});
    Iz = simplify(Iz, IAC{:});
  end
