function bool = issymfunscalar(a, options)
  % -------------------------------
  % - returns true if an array
  %   is a symbolic function scalar
  % -------------------------------
  
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
    bool = isScalar(a, 'symfun');
  else
    func = @(arg) isAlways(arg, 'Unknown', 'false');
    switch Type
      case "positive"
        bool = issymfunscalar(a) && func(a > 0);
      case "positive or zero"
        bool = issymfunscalar(a) && func(a >= 0);
      case "negative"
        bool = issymfunscalar(a) && func(a < 0);
      case "negative or zero"
        bool = issymfunscalar(a) && func(a <= 0);
    end
  end
