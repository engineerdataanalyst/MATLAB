function answer = cscpi(varargin)
  % --------------------
  % - computes csc(pi*x)
  % --------------------
  try
    answer = 1./sinpi(varargin{:});
  catch Error
    throw(Error);
  end
