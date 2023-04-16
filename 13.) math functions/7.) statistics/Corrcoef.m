function R = Corrcoef(x, y, options)
  % ---------------------------------------------
  % - a slight variation of the corrcoef function
  % - will return one single value
  %   for the correlation coefficient
  %   instead of a matrix
  % ---------------------------------------------

  %% check the input arguments
  % check the argument classes
  arguments
    x {mustBeA(x, ["numeric" "sym"])};
    y {mustBeA(y, ["numeric" "sym"])};
    options.Dim (1,1) double ...
    {mustBeMember(options.Dim, [1 2])} = default_dim(x);
  end
  Dim = options.Dim;
  % check for invalid symbolic function arguments
  if ~isequalargnames(x, y, 'CheckSymfunsOnly', true)
    error(message('symbolic:symfun:InputMatch'));
  elseif issymfun(x) || issymfun(y)
    convert2symfun = true;
    args = argnames(x);
    if issymfun(x)
      x = formula(x);
    else
      y = formula(y);
    end
  else
    convert2symfun = false;
  end
  % check for invalid input arguments
  if ~compatible_dims(x, y)
    error('input arguments must have compatible dimensions');
  elseif ~ismatrix(x) || ~ismatrix(y)
    error('input arguments must be matricies');
  end
  [x y] = scalar_expand(x, y);
  %% compute the correlation coefficient
  if Dim == 1
    x = mat2cell(x, height(x), ones(1, width(x)));
    y = mat2cell(y, height(y), ones(1, width(y)));
  else
    x = mat2cell(x, ones(1, height(x)), width(x));
    y = mat2cell(y, ones(1, height(y)), width(y));
  end
  R = cellfun(@Rfunc, x, y);
  %% convert back to symbolic function if necessary
  if convert2symfun
    func = @(X) symfun(X, args);
    if isscalar(R)
      R = func(R);
    else
      R = arrayfun(func, R, 'UniformOutput', false);
    end
  end
end
% =
function dim = default_dim(x)
  % --------------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the correlation coefficient function
  % --------------------------------------
  if isRow(x)
    dim = 2;
  else
    dim = 1;
  end
end
% =
function R = Rfunc(X, Y)
  % -------------------------------
  % - helper function for computing
  %   the correlation coefficient
  % -------------------------------
  N = length(X);
  num = N*sum(X.*Y)-sum(X)*sum(Y);
  den = (N*sum(X.^2)-sum(X)^2)*(N*sum(Y.^2)-sum(Y)^2);
  R = num/sqrt(den);
end
% =
