function answer = Dot(a, b, options)
  % ----------------------------------------
  % - a slight variation of the dot function
  % - will compute the dot product
  %   without using any conjugates
  % ----------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a {mustBeA(a, ["numeric" "sym"])};
    b {mustBeA(b, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  % check the arrays
  if isVector(a) && ~isRow(a)
    a = a.';
  end
  if isVector(b) && ~isRow(b)
    b = b.';
  end
  if ~isequaldim(a, b)
    str = stack('''a'' and ''b'' must have the same dimensions', ...
                'or have the same lengths if they are vectors');
    error(str);
  end
  % check the array dimensions
  Dim = options.Dim;
  if ~ismember(Dim, [1 2])
    error('''Dim'' must be 1 or 2');
  end
  %% compute the dot product of the two vectors
  answer = sum(a.*b, Dim);
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
