function bool = issymvarmultiplescalar(a, options)
  % -------------------------------
  % - returns true if an array
  %   is a numeric multiple
  %   of a symbolic variable scalar
  % -------------------------------
  
  %% check the input arguments
  arguments
    a;
    options.CountZero (1,1) logical = false;
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = issymscalar(a) && issymvarmultiple(a, Args{:});
