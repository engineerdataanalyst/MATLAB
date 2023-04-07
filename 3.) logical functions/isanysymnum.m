function bool = isanysymnum(a, options)
  % ----------------------
  % - returns true if any
  %   element of an array
  %   is a symbolic number
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
  bool = any(issymnum(a, Args{:}), 'all');
