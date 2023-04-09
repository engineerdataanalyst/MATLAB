function bool = issymvararray(a, options)
  % -------------------------------
  % - returns true if an array
  %   is a symbolic variable array
  %   with a specific dimension
  % ------------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = issymarray(a, Args{:}) && isallsymvar(a);
