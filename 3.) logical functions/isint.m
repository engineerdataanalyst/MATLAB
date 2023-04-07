function bool = isint(a, options)
  % -------------------------------
  % - for numeric arrays,
  %   returns a logical array
  %   corresponding to the elements
  %   of a given array that are
  %   integers
  % - for symbolic arrays,
  %   returns a symbolic condition
  %   array stating that the
  %   given array elements are
  %   integers
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
  if (~isnumeric(a) && ~issym(a)) || isEmpty(a)
    bool = false;
  elseif ~isfield(options, 'Type')
    if isnumeric(a)
      reals = isReal(a);
      bool = false(size(a));
      bool(reals) = rem(a(reals), 1) == 0;
    else
      bool = in(a, 'integer');
    end
  else
    switch Type
      case "positive or zero"
        bool = isint(a) & (a >= 0);
      case "positive"
        bool = isint(a) & (a >= 1);
      case "negative or zero"
        bool = isint(a) & (a <= 0);
      case "negative"
        bool = isint(a) & (a <= -1);
    end
  end
