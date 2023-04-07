function bool = isallsymnum(a, options)
  % ----------------------
  % - returns true if all
  %   elements of an array
  %   are symbolic numbers
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
  bool = all(issymnum(a, Args{:}), 'all');
