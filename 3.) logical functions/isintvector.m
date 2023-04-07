function bool = isintvector(a, options)
  % --------------------------
  % - returns true if an array
  %   is an integer vector
  %   with a specific length
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  %% check the array
  Args = namedargs2cell(options);
  bool = (isnumvector(a, Args{:}) || ...
          issymnumvector(a, Args{:})) && isallint(a);
