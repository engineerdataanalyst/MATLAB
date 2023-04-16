function answer = cotpi(varargin)
  % --------------------
  % - computes cot(pi*x)
  % --------------------
  try
    answer = 1./tanpi(varargin{:});
  catch Error
    throw(Error);
  end
