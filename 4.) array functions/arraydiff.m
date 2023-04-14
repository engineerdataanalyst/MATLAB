function a = arraydiff(a, varargin)
  % -------------------------
  % - calls the diff function
  %   on each element of a
  %   symbolic array
  % -------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    varargin sym;
  end
  % check the argument dimensions
  if ~compatible_dims(a, varargin{:})
    error('input arguments must have compatible dimensions');
  end
  [a varargin{:}] = scalar_expand(a, varargin{:});
  %% call the diff function
  try
    func = @(A, varargin) diff(A, varargin{:});
    args = argnames(a);
    a = arrayfun(func, formula(a), varargin{:});
    if ~isempty(args)
      a(args) = a;
    end
  catch Error
    throw(Error);
  end
