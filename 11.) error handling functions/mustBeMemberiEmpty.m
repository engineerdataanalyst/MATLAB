function mustBeMemberiEmpty(a, b)
  arguments
    a;
    b {mustBeText(b), mustBeVector(b)};
  end
  a = lower(array2cellstr(a));
  b = lower(array2cellstr(b));
  if (~isTextArray(a) || ~all(ismember(a, b), 'all')) && ~isempty(a)
    aname = inputname(1);
    if isempty(aname)
      aname = 'arg1';
    end
    nums = num2cellstr(1:length(b)).';
    str = append(nums, repmat({'.) ''%s'''}, size(nums)));    
    str = stack('''%s'' must be', ...
                'one of these strings:', ...
                '---------------------', str{:});    
    if isempty(aname)
      aname = 'arg1';
    end
    str = stack('', str);
    error(str, aname, b{:});
  end
