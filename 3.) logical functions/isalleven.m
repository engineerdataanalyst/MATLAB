function bool = isalleven(a, options)
  % ----------------------
  % - returns true if all
  %   elements of an array
  %   are even integers
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
    bool = iseven(a, Args{:});
  elseif issym(a)
    bool = isAlways(iseven(a, Args{:}), 'Unknown', 'false');
  else
    bool = false;
  end
  bool = all(bool, 'all');
