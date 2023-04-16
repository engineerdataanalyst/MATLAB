function [kxc kyc kzc] = cradius_of_gyration(varargin)
  % --------------------------------
  % - computes the radii of gyration
  %   about the x, y, and z axes,
  %   passing through the centroid,
  %   for a symbolic expression
  % --------------------------------
  try
    [Ixc Iyc Izc] = cmoment_of_inertia(varargin{:});
    A = sym_area(varargin{:});
  catch Error
    throw(Error);
  end
  if ~hasSymType(Ixc, 'int')
    IAC = {'IgnoreAnalyticConstraints' true};
    kxc = simplify(simplifyFraction(sqrt(Ixc./A)), IAC{:});
    kyc = simplify(simplifyFraction(sqrt(Iyc./A)), IAC{:});
    kzc = simplify(simplifyFraction(sqrt(Izc./A)), IAC{:});
  else
    kxc = sqrt(Ixc./A);
    kyc = sqrt(Iyc./A);
    kzc = sqrt(Izc./A);
  end
