function bool = isanysymvarmultiple(a, options)
  % -----------------------
  % - returns true if any
  %   element of an array
  %   is a numeric multiple
  %   of symbolic variable
  % -----------------------
  
  %% check the input arguments
  arguments
    a;
    options.CountZero (1,1) logical;
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = any(issymvarmultiple(a, Args{:}), 'all');
