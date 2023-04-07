function bool = issymfunarray(a, options)
  % ------------------------------
  % - returns true if an array
  %   is a symbolic function array
  %   with a specific dimension
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  % check the array dimension
  if isfield(options, 'Dim')
    Args = {'Dim' options.Dim};
  else
    Args = {};
  end
  % check the empty flag
  if isfield(options, 'CheckEmpty')
    Args = [Args {'CheckEmpty' options.CheckEmpty}];
  else
    Args = [Args {'CheckEmpty' false}];
  end
  % check the array type
  if isfield(options, 'Type')
    Type = lower(options.Type);
  end
  %% check the array
  if ~isfield(options, 'Type')
    bool = isArray(a, 'symfun', Args{:});
  elseif isfield(options, 'CheckEmpty')
    str = stack('cannot specify a ''CheckEmpty'' flag', ...
                'and a ''Type'' flag at the same time');
    error(str);
  else
    Args{end} = true;
    func = @(arg) all(isAlways(arg, 'Unknown', 'false'), 'all');
    switch Type
      case "positive"
        bool = issymfunarray(a, Args{:}) && func(a > 0);
      case "positive or zero"
        bool = issymfunarray(a, Args{:}) && func(a >= 0);
      case "negative"
        bool = issymfunarray(a, Args{:}) && func(a < 0);
      case "negative or zero"
        bool = issymfunarray(a, Args{:}) && func(a <= 0);
    end
  end
