function answer = angle_between(a, b, options)
  % ---------------------
  % - computes the angle
  %   between two vectors
  % ---------------------
  
  %% check the input arguments  
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
    b {mustBeA(b, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  Args = namedargs2cell(options);
  %% compute the angle between the two vectors
  try
    num = Dot(a, b, Args{:});
    den = Norm(a, Args{:}).*Norm(b, Args{:});
    answer = acosd(num./den);
    if issym(a) || issym(b)
      answer = answer*symunit('deg');
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
