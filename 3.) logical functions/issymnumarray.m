function bool = issymnumarray(a, options)
  % ----------------------------
  % - returns true if an array
  %   is a symbolic number array
  %   with a specific dimension  
  % ----------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = issymarray(a, Args{:}) && isallsymnum(a);
