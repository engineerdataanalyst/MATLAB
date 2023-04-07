function bool = isevenscalar(a, options)
  % ---------------------------
  % - returns true if an array
  %   is an even integer scalar
  % ---------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = (isnumscalar(a, Args{:}) || ...
          issymscalar(a, Args{:})) && isalleven(a);
