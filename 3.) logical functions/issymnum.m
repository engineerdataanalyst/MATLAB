function bool = issymnum(a, options)
  % ---------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are symbolic numbers
  % ---------------------------
  
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
    Type = options.Type;
  end
  %% check the array
  if ~isfield(options, 'Type')
    if ~issym(a)
      bool = false;
    elseif isEmpty(a)
      bool = true;
    else
      a = release(formula(a));
      symvars = arrayfun(@symvar, a, 'UniformOutput', false);
      bool = cellfun(@isempty, symvars);
    end
  else
    func = @(arg) isAlways(arg, 'Unknown', 'false');
    switch Type
      case "positive or zero"
        bool = issymnum(a) & func(a >= 0);
      case "positive"
        bool = issymnum(a) & func(a > 0);
      case "negative or zero"
        bool = issymnum(a) & func(a <= 0);
      case "negative"
        bool = issymnum(a) & func(a < 0);
    end
  end
