function bool = isStringRow(a, options)
  % --------------------------
  % - returns true if an array
  %   is a string row vector
  %   with a specific length
  %   and number of characters
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    options.ArrayLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.TextLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyArray (1,1) logical = false;
    options.CheckEmptyText (1,1) logical = false;
  end
  %% compute the flags
  if isfield(options, 'ArrayLen')
    ArrayLen = options.ArrayLen;
  else
    ArrayLen = [];
  end
  if isfield(options, 'TextLen')
    TextLen = options.TextLen;
  else
    TextLen = [];
  end
  CheckEmptyArray = options.CheckEmptyArray;
  CheckEmptyText = options.CheckEmptyText;
  %% compute the test function handles
  % function handles for the length flags
  if ~isempty(ArrayLen) && ~isempty(TextLen)
    valid_len = @(arg) islen(arg, ArrayLen) && ...
                       all(strlength(arg) == TextLen);
  elseif ~isempty(ArrayLen) && isempty(TextLen)
    valid_len = @(arg) islen(arg, ArrayLen);
  elseif isempty(ArrayLen) && ~isempty(TextLen)
    valid_len = @(arg) all(strlength(arg) == TextLen);
  else
    valid_len = @(~) true;
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
  bool = isRow(a, 'string') && valid_len(a) && non_empty(a);
