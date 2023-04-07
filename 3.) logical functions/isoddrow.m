function bool = isoddrow(a, options)
  % ------------------------------
  % - returns true if an array
  %   is an odd integer row vector
  %   with a specific length
  % ------------------------------
  
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
  bool = (isnumrow(a, Args{:}) || ...
          issymrow(a, Args{:})) && isallodd(a);
