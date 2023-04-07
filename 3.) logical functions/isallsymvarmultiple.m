function bool = isallsymvarmultiple(a, options)
  % -----------------------
  % - returns true if all
  %   elements of an array
  %   are numeric multiples
  %   of symbolic variables
  % -----------------------
  
  %% check the input arguments
  arguments
    a;
    options.CountZero (1,1) logical;
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = all(issymvarmultiple(a, Args{:}), 'all');
