function [Ixc Iyc Izc] = cmoment_of_inertia(varargin)
  % --------------------------------
  % - computes the moment of inertia
  %   about the x, y, and z axes,
  %   passing through the centroid,   
  %   for a symbolic expression
  % --------------------------------
  try
    [Ix Iy] = moment_of_inertia(varargin{:});
    A = sym_area(varargin{:});
    [xc yc] = centroid(varargin{:});
  catch Error
    throw(Error);
  end
  if ~hasSymType(Ix, 'int')
    IAc = {'IgnoreAnalyticConstraints' true};
    Ixc = simplify(simplifyFraction(Ix-A.*yc.^2), IAc{:});
    Iyc = simplify(simplifyFraction(Iy-A.*xc.^2), IAc{:});
    Izc = simplify(simplifyFraction(Ixc+Iyc), IAc{:});
  else
    Ixc = Ix-A.*yc.^2;
    Iyc = Iy-A.*xc.^2;
    Izc = Ixc+Iyc;
  end
