function a = convert2identifier(a, trim_underscores)
  % ------------------------------
  % - converts an array of strings
  %   to valid MATLAB identifiers
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a {mustBeText};
    trim_underscores logical = true;
  end
  % check the underscores flag
  if isempty(a)
    valid_flag = islogscalar(trim_underscores);
  elseif isvector(a)
    valid_flag = islogvector(trim_underscores, ...
                             'Len', length(a), 'CheckEmpty', true) || ...
                 isscalar(trim_underscores);
  else
    valid_flag = islogarray(trim_underscores, 'Dim', size(a)) || ...
                 isscalar(trim_underscores);
  end
  if ~valid_flag
    a = stack('''trim_underscores'' must be:', ...
              '---------------------------', ...
              '1.) a logical scalar', ...
              '2.) a non-empty logical vector with', ...
              '    the same length as ''a''', ...
              '3.) a non-empty logical array', ...
              '    with the same dimensions as ''a''');
    error(a);
  end
  %% modify the input arguments as needed
  if ischar(a)
    convert2char = true;
    a = string(a);
  else
    convert2char = false;
  end
  [~, trim_underscores] = scalar_expand(a, trim_underscores);
  %% convert the strings to valid MATLAB identifiers
  % trim the strings and remove illegal identifier characters
  uniform = {'UniformOutput' false};
  func = @(arg) regexprep(arg, '\W', '_');
  if iscell(a)
    a = cellfun(@strtrim, a, uniform{:});
    a = cellfun(func, a, uniform{:});
  else
    a = arrayfun(@strtrim, a);
    a = arrayfun(func, a);
  end
  % fix the strings if they starts with a number or underscore
  func = {@(arg) isvarname(arg) || (strlength(arg) == 0);
          @(arg) horzcat('x', arg);
          @(arg) "x"+arg};
  if iscell(a)
    varnames = cellfun(func{1}, a);
    a(~varnames) = cellfun(func{2}, a(~varnames), uniform{:});
  else
    varnames = arrayfun(func{1}, a);
    a(~varnames) = arrayfun(func{3}, a(~varnames));
  end
  % trim underscores to unique values if requested
  if any(trim_underscores, 'all')
    if ~isscalar(a) && isscalar(trim_underscores)
      trim_underscores = repmat(trim_underscores, size(a));
    end
    for k = find(trim_underscores(:)).'
      if ~isempty(a) && ~isempty(a{k})
        a{k} = ['x' a{k} 'x'];
        a{k} = regexprep(a{k}, '(?<=\w)_{2,}(?=\w)', '_');
        a{k}([1 end]) = [];
      end
    end
  end
  %% convert back to the original type if ncecessary
  if convert2char
    a = char(a);
  end
