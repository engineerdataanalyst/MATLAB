function answer = proj(a, b, options)
  % ---------------------------
  % - computes the projection 
  %   onto vector a of vector b
  % ---------------------------
  
  %% check the input arguments  
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
    b {mustBeA(b, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  Args = namedargs2cell(options);
  %% compute the vector projection
  try
    num = Dot(a, b, Args{:});
    den = Dot(a, a, Args{:});
    answer = num./den.*a;
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
  if isVector(a) && ~isRow(a)
    a = a.';
  end
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
