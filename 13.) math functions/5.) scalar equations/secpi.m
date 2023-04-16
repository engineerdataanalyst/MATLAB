function answer = secpi(varargin)
  % --------------------
  % - computes sec(pi*x)
  % --------------------
  try
    answer = 1./cospi(varargin{:});
  catch Error
    throw(Error);
  end
