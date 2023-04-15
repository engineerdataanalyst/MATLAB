function varargout = symplot(varargin)
  % ---------------------------
  % - plots a symbolic function
  % ---------------------------
  
  %% parse the input arguments
  % compute the plotting function and variable
  narginchk(2,inf);
  f = varargin{1};
  if isScalar(varargin{2})
    x = varargin{2};
    options = varargin(3:end);
  else
    if isallsymnum(f)
      x = sym('x');
    elseif issym(f)
      x = symvar(f, 1);
    else
      x = [];
    end
    options = varargin(2:end);
  end  
  % compute the plotting range
  if ~isempty(options)
    range = options{1};
    options = options(2:end);
  else
    range = [];
  end
  % compute the sublist
  if ~isempty(options) && ...
    (~isTextScalar(options{1}, ["char" "string"]) || isempty(options{1}))
    if ~isempty(options{1})
      sublist = options{1};
    else
      sublist = 'empty';
    end
    options = options(2:end);
  else
    sublist = [];
  end
  % compute the subvals
  if ~isempty(options) && ...
    (~isTextScalar(options{1}, ["char" "string"]) || isempty(options{1}))
    if ~isempty(options{1})
      subvals = options{1};
    else
      subvals = 'empty';
    end
    options = options(2:end);
  elseif ~isequal(sublist, [])
    subvals = 'empty';
  else
    subvals = [];
  end  
  %% check the input arguments
  % check the plotting function  
  if ~issymscalar(f)
    error('''f'' must be a symbolic scalar');
  end
  f = formula(removeUnits(f));
  % check the plotting variable
  if ~issymvarscalar(x)
    error('''x'' must be a symbolic variable scalar');
  end
  x = formula(removeUnits(x));
  % check the plotting range
  if issym(range)
    range = formula(removeUnits(range));
  end
  if ~isnumvector(range, 'Len', 2) && ~issymnumvector(range, 'Len', 2)
    str = stack('''range'' must be:', ...
                '----------------', ...
                '1.) a numeric vector of length 2', ...
                '2.) a symbolic vector of length 2 with only numbers');
    error(str);
  end
  if ~isnumeric(range)
    range = double(range);
  end
  if ~isrow(range)
    range = range.';
  end
  % check the sublist type
  if issym(sublist)
    sublist = formula(removeUnits(sublist));
  end
  if (~issymvarvector(sublist) || ~isunique(sublist)) && ...
      ~isempty(sublist)
    error('''sublist'' must be a symbolic vector of unique variables');
  end
  % check the subvals type
  if issym(subvals)
    subvals = formula(removeUnits(subvals));
  end
  if ~isnumvector(subvals) && ~issymnumvector(subvals) && ~isempty(subvals)
    str = stack('''subvals'' must be:', ...
                '------------------', ...
                '1.) a numeric vector or', ...
                '2.) a symbolic vector with only numbers');
    error(str);
  end
  % check the lengths of sublist and subvals
  [sublist subvals] = scalar_expand(sublist, subvals);
  if ~isequallen(sublist, subvals)
    str = stack('''sublist'' and ''subvals''', ...
                'must have the same lengths');
    error(str);
  end
  % check for a valid sublist
  varlist = symvar(f);
  vars_not_in_varlist = setdiff(sublist, varlist);
  loc = ismember(sublist, vars_not_in_varlist);
  sublist(loc) = [];
  subvals(loc) = [];
  x_found = ismember(x, sublist);
  varlist(ismember(varlist, x)) = [];
  vars_found = all(ismember(varlist, sublist)) || isempty(sublist);
  if x_found || ~vars_found
    str = stack('''sublist'' must contain', ...
                'all the variables of the plotting function', ...
                '(except the plotting variable: ''%s'')');
    error(str, x);
  end
  %% plot the symbolic function
  if isempty(sublist) && ~isempty(varlist)
    num_vars = length(varlist);
    sublist = varlist;
    subvals = zeros(num_vars, 1);
    for k = 1:num_vars
      var = char(varlist(k));
      valid_num = false;
      while ~valid_num
        prompt = sprintf('\nEnter the value for ''%s'': ', var);
        num = input(prompt);
        valid_num = isnumscalar(num);
        if ~valid_num
          prompt = '\n.....The value must be a numeric scalar\n';
          fprintf(prompt);
        end
      end
      subvals(k) = num;
    end
    fprintf('\n');
  end
  f = subs(f, sublist(:), subvals(:));
  [varargout{1:nargout}] = fplot(f, range, options{:});
