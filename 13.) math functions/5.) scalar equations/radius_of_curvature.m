function R = radius_of_curvature(varargin)
  % ----------------------------------
  % - computes the radius of curvature
  %   of a symbolic expression
  % ----------------------------------
  try
    R = 1./curvature(varargin{:});
  catch Error
    throw(Error);
  end
