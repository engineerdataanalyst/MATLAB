function bool = isoddarray(a, options)
  % ---------------------------
  % - returns true if an array
  %   is an odd integer array
  %   with a specific dimension
  % ---------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "negative"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = (isnumarray(a, Args{:}) || ...
          issymarray(a, Args{:})) && isallodd(a);
