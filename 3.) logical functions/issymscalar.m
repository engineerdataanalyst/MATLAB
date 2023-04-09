function bool = issymscalar(a, options)
  % --------------------------
  % - returns true if an array
  %   is a symbolic scalar
  % --------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  % check the array type
  if isfield(options, 'Type')
    Type = lower(options.Type);
  end
  %% check the array
  if ~isfield(options, 'Type')
    bool = isScalar(a, 'sym');
  else
    func = @(arg) isAlways(arg, 'Unknown', 'false');
    switch Type
      case "positive"
        bool = issymscalar(a) && func(a > 0);
      case "positive or zero"
        bool = issymscalar(a) && func(a >= 0);
      case "negative"
        bool = issymscalar(a) && func(a < 0);
      case "negative or zero"
        bool = issymscalar(a) && func(a <= 0);
    end
  end
