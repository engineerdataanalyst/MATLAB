function bool = issymvarmultiplecol(a, options)
  % --------------------------------------
  % - returns true if an array
  %   is a numeric multiple
  %   of a symbolic variable column vector
  %   with a specific length
  % --------------------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CountZero (1,1) logical = false;
  end
  %% check the array
  Args = namedargs2cell(options);
  if ~isfield(options, 'Len')
    bool = issymcol(a) && isallsymvarmultiple(a, Args{:});
  else
    bool = issymcol(a, Args{1:2}) && ...
           isallsymvarmultiple(a, Args{3:end});
  end
