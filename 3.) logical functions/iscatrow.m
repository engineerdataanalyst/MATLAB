function bool = iscatrow(a, options)
  % -----------------------------
  % - returns true if an array
  %   is a categorical row vector
  %   with a specific length
  % -----------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical;
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = isRow(a, 'categorical', Args{:});
