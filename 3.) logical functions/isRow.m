function bool = isRow(a, classname, options)
  % -------------------------------
  % - returns true if an array
  %   is a row vector
  %   with specific type and length
  % -------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector} = 'classname';
    options.Len (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmpty (1,1) logical = false;
  end
  % check the array length
  if isfield(options, 'Len')
    Len = options.Len;
  else
    Len = [];
  end
  % check the empty flag
  CheckEmpty = options.CheckEmpty;
  %% check the array
  if isempty(Len) && ~CheckEmpty
    if nargin == 1
      if issymfun(a)
        bool = isrow(formula(a));
      else
        bool = isrow(a);
      end
    else
      func = @(arg) isa(a, arg);
      classname = unique(string(classname), 'stable');
      bool = any(arrayfun(func, classname)) && isRow(a);
    end
  elseif ~isempty(Len) && ~CheckEmpty
    if nargin == 1
      bool = isRow(a) && islen(a, Len);
    else
      bool = isRow(a, classname) && islen(a, Len);
    end
  elseif isempty(Len) && CheckEmpty
    if nargin == 1
      bool = isRow(a) && ~isEmpty(a);
    else
      bool = isRow(a, classname) && ~isEmpty(a);
    end
  elseif ~isempty(Len) && CheckEmpty
    if nargin == 1
      bool = isRow(a, 'Len', Len) && ~isEmpty(a);
    else
      bool = isRow(a, classname, 'Len', Len) && ~isEmpty(a);
    end
  end
