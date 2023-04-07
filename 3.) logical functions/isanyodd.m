function bool = isanyodd(a, options)
  % ----------------------
  % - returns true if any
  %   element of an array
  %   is an odd integer
  % ----------------------
  
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
  if isnumeric(a)
    bool = isodd(a, Args{:});
  elseif issym(a)
    bool = isAlways(isodd(a, Args{:}), 'Unknown', 'false');
  else
    bool = false;
  end
  bool = any(bool, 'all');
