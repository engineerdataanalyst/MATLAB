function bool = iscatmatrix(a, options)
  % ---------------------------
  % - returns true if an array
  %   is a categorical matrix
  %   with a specific dimension
  % ---------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical;
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = isMatrix(a, 'categorical', Args{:});
