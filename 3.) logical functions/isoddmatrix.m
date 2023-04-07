function bool = isoddmatrix(a, options)
  % ---------------------------
  % - returns true if an array
  %   is an odd integer matrix
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
  bool = (isnummatrix(a, Args{:}) || ...
          issymmatrix(a, Args{:})) && isallodd(a);
