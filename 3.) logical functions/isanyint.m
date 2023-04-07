function bool = isanyint(a, options)
  % ----------------------
  % - returns true if any
  %   element of an array
  %   is an integer
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
  %% check the array
  Args = namedargs2cell(options);
  if isnumeric(a)
    bool = isint(a, Args{:});
  elseif issym(a)
    bool = isAlways(isint(a, Args{:}), 'Unknown', 'false');
  else
    bool = false;
  end
  bool = any(bool, 'all');
