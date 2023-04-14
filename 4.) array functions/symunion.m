function a = symunion(a, options)
  % ------------------------------------------
  % - a slight variation of the union function
  % - will first convert all compatible units
  %   of a symbolic array to the same units,
  %   then will union all of the arrays
  % ------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    a sym;
  end
  arguments
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["ascend" "descend"])} = "ascend";
  end
  options = namedargs2cell(options);
  % check the symbolic array arguments
  if length(a) < 2
    str = stack('there must be at least 2 symbolic arrays', ...
                'passed as an input argument');
    error(str);
  end
  %% compute the union of the symbolic arrays
  rows = cellfun(@isRow, a);
  a = convert2row(a);
  a = symunique([a{:}], options{:});
  if ~all(rows)
    a = a.';
  end
