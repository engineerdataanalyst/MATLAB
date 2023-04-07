function bool = isStringScalar2(a, options)
  % --------------------------
  % - returns true if an array
  %   is a string scalar
  %   with a specific
  %   number of characters
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    options.TextLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyText (1,1) logical = false;
  end
  %% compute the flags
  if isfield(options, 'TextLen')
    TextLen = options.TextLen;
  else
    TextLen = [];
  end
  CheckEmptyText = options.CheckEmptyText;
  %% compute the test function handles
  % function handles for the length flags
  if ~isempty(TextLen)
    valid_len = @(arg) strlength(arg) == TextLen;
  else
    valid_len = @(~) true;
  end
  % function handles for the empty flags
  if CheckEmptyText
    non_empty = @(arg) strlength(arg) ~= 0;
  else
    non_empty = @(~) true;
  end
  %% check the array
  bool = isStringScalar(a) && valid_len(a) && non_empty(a);
