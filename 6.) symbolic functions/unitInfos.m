function varargout = unitInfos(a)
  % ---------------------------------------------
  % - a slight variation of the unitInfo function
  % - will call the unitInfo function on
  %   multiple units instead of only one unit
  % ---------------------------------------------
  
  %% check the number of input and output arguments
  narginchk(0,1);
  nargoutchk(0,1);
  if nargin == 0
    [varargout{1:nargout}] = unitInfo;
    return;  
  elseif issymfun(a)
    a = formula(a);
  elseif ischar(a)
    a = {a};
  end
  %% check the input argument
  units = isallsymunit(a);
  if ~units && ...
     ~isTextArray(a, 'CheckEmptyArray', true, 'CheckEmptyText', true) && ...
     ~isStringArray(a, 'CheckEmptyArray', true, 'CheckEmptyText', true)
    str = stack('input argument must be:', ...
                '-----------------------', ...
                '1.) a symbolic array of units', ...
                '2.) a non-empty string', ...
                '3.) a non-empty cell array of non-empty strings', ...
                '4.) a non-empty string array of non-empty strings');
    error(str);
  end
  %% call the unitInfo function
  uniform = {'UniformOutput' false};
  if units
    [varargout{1:nargout}] = arrayfun(@unitInfo, a);
  else
    [varargout{1:nargout}] = cellfun(@unitInfo, a, uniform{:});
  end
