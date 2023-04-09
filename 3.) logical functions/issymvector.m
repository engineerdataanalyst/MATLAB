function bool = issymvector(a, options)
  % --------------------------
  % - returns true if an array
  %   is a symbolic vector
  %   with a specific length
  % --------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["positive" ...
                                  "positive or zero" ...
                                  "negative" ...
                                  "negative or zero"])};
  end
  % check the array length
  if isfield(options, 'Len')
    Args = {'Len' options.Len};
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
    bool = isVector(a, 'sym', Args{:});
  elseif isfield(options, 'CheckEmpty')
    str = stack('cannot specify a ''CheckEmpty'' flag', ...
                'and a ''Type'' flag at the same time');
    error(str);
  else
    Args{end} = true;
    func = @(arg) all(isAlways(arg, 'Unknown', 'false'), 'all');
    switch Type
      case "positive"
        bool = issymvector(a, Args{:}) && func(a > 0);
      case "positive or zero"
        bool = issymvector(a, Args{:}) && func(a >= 0);
      case "negative"
        bool = issymvector(a, Args{:}) && func(a < 0);
      case "negative or zero"
        bool = issymvector(a, Args{:}) && func(a <= 0);
    end
  end
