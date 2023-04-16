function [kx ky kz] = radius_of_gyration(varargin)
  % --------------------------------
  % - computes the radii of gyration
  %   about the x, y, and z axes
  %   for a symbolic expression
  % --------------------------------
  try
    [Ix Iy Iz] = moment_of_inertia(varargin{:});
    A = sym_area(varargin{:});
  catch Error
    throw(Error);
  end
  IAC = {'IgnoreAnalyticConstraints' true};
  if ~hasSymType(Ix, 'int')
    kx = simplify(simplifyFraction(sqrt(Ix./A)), IAC{:});
    ky = simplify(simplifyFraction(sqrt(Iy./A)), IAC{:});
    kz = simplify(simplifyFraction(sqrt(Iz./A)), IAC{:});
  else
    kx = sqrt(Ix./A);
    ky = sqrt(Iy./A);
    kz = sqrt(Iz./A);
  end
