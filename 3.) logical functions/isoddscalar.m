function bool = isoddscalar(a, options)
  % --------------------------
  % - returns true if an array
  %   is an odd integer scalar
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "negative"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = (isnumscalar(a, Args{:}) || ...
          issymscalar(a, Args{:})) && isallodd(a);
