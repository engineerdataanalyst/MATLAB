function answer = tanpi(varargin)
  % --------------------
  % - computes tan(pi*x)
  % --------------------
  try
    answer = sinpi(varargin{:})./cospi(varargin{:});
  catch Error
    throw(Error);
  end
