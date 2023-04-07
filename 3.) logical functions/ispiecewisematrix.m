function bool = ispiecewisematrix(a, options)
  % ---------------------------
  % - returns true if an array
  %   is a piecewise matrix
  %   with a specific dimension
  % ---------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = issymmatrix(a, Args{:}) && isallpiecewise(a);
