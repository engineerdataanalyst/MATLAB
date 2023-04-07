function bool = isdim(a, dim)
  % ---------------------------
  % - returns true if an array
  %   has a specified dimension
  % ---------------------------
  
  %% check the input arguments  
  arguments
    a;
    dim (1,:) double {mustBeNonempty, mustBeInteger, mustBeNonnegative};
  end
  %% check the array
  if isscalar(dim)
    dim = repmat(dim, 1, 2);
  end
  right_dim = dim(Ndims(a)+1:end);
  if any(right_dim) && all(right_dim == 1)
    dim(Ndims(a)+1:end) = [];
  end
  bool = isequal(Size(a), dim);
