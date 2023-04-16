function Ixyc = cproduct_of_inertia(varargin)
  % ---------------------------------------
  % - computes the product of inertia
  %   about the x and y axes,
  %   passing through the centroid of area,   
  %   for a symbolic expression
  % ---------------------------------------
  try
    Ixy = product_of_inertia(varargin{:});
    A = sym_area(varargin{:});
    [xc yc] = centroid(varargin{:});
  catch Error
    throw(Error);
  end
  if ~hasSymType(Ixy, 'int')
    IAC = {'IgnoreAnalyticConstraints' true};
    Ixyc = simplify(simplifyFraction(Ixy-A.*xc.*yc), IAC{:});
  else
    Ixyc = Ixy-A.*xc.*yc;
  end
