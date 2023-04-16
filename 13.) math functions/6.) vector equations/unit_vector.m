function answer = unit_vector(a, options)
  % ----------------------------------
  % - computes the unit vector in the
  %   same direction of a given vector
  % ----------------------------------
  
  %% check the input arguments
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  Args = namedargs2cell(options);
  %% compute the unit vectors
  try
    if isMatrix(a)
      answer = a./Norm(a, Args{:});
    else
      answer = a;
      a_size = Size(a);
      for k = 1:prod(a_size(3:end))
        answer(:,:,k) = unit_vector(a(:,:,k), Args{:});
      end
    end
  catch Error
    throw(Error);
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the arrays
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
