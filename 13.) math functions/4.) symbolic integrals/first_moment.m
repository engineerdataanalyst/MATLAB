function [Qx Qy] = first_moment(varargin)
  % -----------------------------------
  % - computes the first moment of area
  %   for a symbolic expression  
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
      integrandx = y.^2/2;
      integrandy = x*y;
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Qx = int(integrandx, x, range, options{:});
      Qy = int(integrandy, x, range, options{:});
    case "polar"
      r = s.y;
      theta = s.x;
      integrandx = r.^3/3*sin(theta);
      integrandy = r.^3/3*cos(theta);
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Qx = int(integrandx, theta, range, options{:});
      Qy = int(integrandy, theta, range, options{:});
    case "parametric"
      xt = s.xt;
      yt = s.yt;
      dxt = s.dxt;
      t = s.t;
      integrandx = yt.^2/2.*dxt;
      integrandy = xt.*yt.*dxt;
      integrandx = simplify(simplifyFraction(integrandx), IAC{:});
      integrandy = simplify(simplifyFraction(integrandy), IAC{:});
      Qx = int(integrandx, t, range, options{:});
      Qy = int(integrandy, t, range, options{:});
  end
  if ~hasSymType(Qx, 'int')
    Qx = simplify(Qx, IAC{:});
    Qy = simplify(Qy, IAC{:});
  end
