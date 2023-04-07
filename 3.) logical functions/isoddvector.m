function bool = isoddvector(a, options)
  % --------------------------
  % - returns true if an array
  %   is an odd integer vector
  %   with a specific length
  % --------------------------
  
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
  bool = (isnumvector(a, Args{:}) || ...
          issymvector(a, Args{:})) && isallodd(a);
