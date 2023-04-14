function str = stack(varargin)
  % ----------------------------------
  % - stacks a given number of strings
  %   on top of one another
  % ----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    varargin {mustBeTextScalar};
  end
  % check the number of input arguments
  narginchk(1,inf);
  %% stack the strings
  if any(cellfun(@isstring, varargin))
    varargin = string(varargin);
  end
  str = strjoin(varargin, newline);
