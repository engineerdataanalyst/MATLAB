function bool = isanyeven(a, options)
  % ----------------------
  % - returns true if any
  %   element of an array
  %   is an even integer
  % ----------------------
  
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
  Args = namedargs2cell(options);
  %% check the array
  if isnumeric(a)
    bool = iseven(a, Args{:});
  elseif issym(a)
    bool = isAlways(iseven(a, Args{:}), 'Unknown', 'false');
  else
    bool = false;
  end
  bool = any(bool, 'all');
