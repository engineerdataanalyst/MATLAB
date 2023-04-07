function bool = isArray(a, classname, options)
  % ----------------------------------
  % - returns true if an array
  %   is a specific type and dimension
  % ----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector} = 'classname';
    options.Dim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical = false;
  end
  % check the array dimension
  if isfield(options, 'Dim')
    Dim = options.Dim;
  else
    Dim = [];
  end
  % check the empty flag
  CheckEmpty = options.CheckEmpty;
  %% check the array
  if isempty(Dim) && ~CheckEmpty
    if nargin == 1
      bool = true;
    else
      func = @(arg) isa(a, arg);
      classname = unique(string(classname), 'stable');
      bool = any(arrayfun(func, classname)) && isArray(a);
    end
  elseif ~isempty(Dim) && ~CheckEmpty
    if nargin == 1
      bool = isArray(a) && isdim(a, Dim);
    else
      bool = isArray(a, classname) && isdim(a, Dim);
    end
  elseif isempty(Dim) && CheckEmpty
    if nargin == 1
      bool = isArray(a) && ~isEmpty(a);
    else
      bool = isArray(a, classname) && ~isEmpty(a);
    end
  elseif ~isempty(Dim) && CheckEmpty
    if nargin == 1
      bool = isArray(a, 'Dim', Dim) && ~isEmpty(a);
    else
      bool = isArray(a, classname, 'Dim', Dim) && ~isEmpty(a);
    end
  end
