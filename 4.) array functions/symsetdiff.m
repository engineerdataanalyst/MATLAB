function [c inda] = symsetdiff(a, b, options)
  % ---------------------------------------------
  % - a slight variation of the sectdiff function
  % - will first convert all consistent units
  %   of a symbolic expresssion to the same units,
  %   then will call the symunique function
  %   and the symismember function function
  % ---------------------------------------------
  
  %% check the input arguments
  arguments
    a sym;
    b sym;
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["ascend" "descend"])} = "ascend";
  end
  %% convert symbolic functions to symbolic arrays
  if issymfun(a) || issymfun(b)
    convert2symfun = true;
    if issymfun(a)
      args.a = argnames(a);
      a = formula(a);
    else
      args.a = [];
    end
    if issymfun(b)
      args.b = argnames(b);
      b = formula(b);
    else
      args.b = [];
    end
    if ~isequal(args.a, args.b)
      error(message('symbolic:symfun:InputMatch'));
    end
  else
    convert2symfun = false;
  end
  %% compute the setdiff of the sym arrays
  Args = namedargs2cell(options);
  loc = ~symismember(a, b);
  c = symunique(a(loc), Args{:});
  if convert2symfun
    c(args.a) = a;
  end
  if isrow(c) && ~isrow(b)
    c = c.';
  end
  %% compute the setdiff indicies
  if nargout ~= 2
    return;
  end
  inda = [];
  for k = 1:length(c)
    equal = isAlways(c(k) == a(:), 'Unknown', 'false');
    if any(equal)
      inda = [inda; find(equal, 1)];
    end
  end
