function bool = isoddcol(a, options)
  % ---------------------------------
  % - returns true if an array
  %   is an odd integer column vector
  %   with a specific length
  % ---------------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "negative"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = (isnumcol(a, Args{:}) || ...
          issymcol(a, Args{:})) && isallodd(a);
