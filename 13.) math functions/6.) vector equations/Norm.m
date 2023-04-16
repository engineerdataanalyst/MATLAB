function answer = Norm(a, options)
  % -----------------------------------------
  % - a slight variation of the norm function
  % - will compute the magnitude of a vector
  %   without using any absolute values
  % -----------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  % check the array dimensions
  Dim = options.Dim;
  if ~ismember(Dim, [1 2])
    error('''Dim'' must be 1 or 2');
  end
  %% compute the magnitude of the vectors
  if isScalar(a)
    answer = a;
  else
    answer = sqrt(sum(a.^2, Dim));
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the array
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end  
end
% =
