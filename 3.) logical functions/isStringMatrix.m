function bool = isStringMatrix(a, options)
  % --------------------------
  % - returns true if an array
  %   is a string matrix
  %   with a specific length
  %   and number of characters
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    options.ArrayDim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.TextLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyArray (1,1) logical = false;
    options.CheckEmptyText (1,1) logical = false;
  end
  %% compute the flags
  if isfield(options, 'ArrayDim')
    ArrayDim = options.ArrayDim;
  else
    ArrayDim = [];
  end
  if isfield(options, 'TextLen')
    TextLen = options.TextLen;
  else
    TextLen = [];
  end
  CheckEmptyArray = options.CheckEmptyArray;
  CheckEmptyText = options.CheckEmptyText;
  %% compute the test function handles
  % function handles for the dimension flags
  if ~isempty(ArrayDim) && ~isempty(TextLen)
    valid_dim = @(arg) isdim(arg, ArrayDim) && ...
                       all(strlength(arg) == TextLen);
  elseif ~isempty(ArrayDim) && isempty(TextLen)
    valid_dim = @(arg) isdim(arg, ArrayDim);
  elseif isempty(ArrayDim) && ~isempty(TextLen)
    valid_dim = @(arg) all(strlength(arg) == TextLen);
  else
    valid_dim = @(~) true;
  end
  % function handles for the empty flags
  if CheckEmptyArray && CheckEmptyText
    non_empty = @(arg) ~isempty(arg) && all(strlength(arg) ~= 0);
  elseif ~CheckEmptyArray && CheckEmptyText
    non_empty = @(arg) all(strlength(arg) ~= 0);
  elseif CheckEmptyArray && ~CheckEmptyText
    non_empty = @(arg) ~isempty(arg);
  else
    non_empty = @(~) true;
  end
  %% check the array
  bool = isMatrix(a, 'string') && valid_dim(a) && non_empty(a);
