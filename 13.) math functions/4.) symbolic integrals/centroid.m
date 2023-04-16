function [xc yc rc] = centroid(varargin)
  % --------------------------------------
  % - computes the x, y, and r coordinates
  %   of the centroid location
  %   for a symbolic expression
  % --------------------------------------
  try
    [Qx Qy] = first_moment(varargin{:});
    A = sym_area(varargin{:});
  catch Error
    throw(Error);
  end
  if hasSymType(Qx, 'int')
    IAC = {'IgnoreAnalyticConstraints' true};
    xc = simplify(simplifyFraction(Qy./A), IAC{:});
    yc = simplify(simplifyFraction(Qx./A), IAC{:});
    rc = simplify(simplifyFraction(sqrt(xc.^2+yc.^2)), IAC{:});
  else
    xc = Qy./A;
    yc = Qx./A;
    rc = sqrt(xc.^2+yc.^2);
  end
