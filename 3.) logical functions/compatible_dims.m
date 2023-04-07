function bool = compatible_dims(varargin)
  % -------------------------------------
  % - returns true if all input arguments
  %   have compatible dimensions
  % -------------------------------------
  narginchk(1,inf);
  scalars = cellfun(@isScalar, varargin);
  case1 = isequaldim(varargin{:});
  case2 = any(~scalars) && isequaldim(varargin{~scalars});
  bool = case1 || case2;
