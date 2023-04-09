function bool = issymvarmultiplematrix(a, options)
  % -------------------------------
  % - returns true if an array
  %   is a numeric multiple
  %   of a symbolic variable matrix
  %   with a specific dimension
  % -------------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CountZero (1,1) logical = false;
  end
  %% check the array
  Args = namedargs2cell(options);
  if ~isfield(options, 'Dim')
    bool = issymmatrix(a) && isallsymvarmultiple(a, Args{:});
  else
    bool = issymmatrix(a, Args{1:2}) && ...
           isallsymvarmultiple(a, Args{3:end});
  end
