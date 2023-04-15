function f = itsymsum(g, index, varargin)
  % ------------------------------------------
  % - returns the iterative symbolic summation
  %   of a symbolic scalar
  % ------------------------------------------
  
  %% check the input arguments
  % check the 'g' argument
  narginchk(3,inf);
  if ~isnumscalar(g) && ~issymscalar(g)    
    error('''g'' must be a numeric or symbolic scalar');
  end
  % check the 'index' argument
  if ~issymvarvector(index) || ~isunique(index)
    str = stack('''index'' must be a symbolic vector', ...
                'of unique symbolic variables');
    error(str);
  end
  % check the 'range' arguments
  range = varargin;
  func = {@(arg) isnumvector(arg, 'Len', 2);
          @(arg) issymvector(arg, 'Len', 2)};
  numeric = cellfun(func{1}, range);
  symbolic = cellfun(func{2}, range);
  if ~all(numeric | symbolic)
    str = stack('''range'' arguments must be', ...
                'numeric or symbolic vectors of length 2');
    error(str);
  end
  % check for matching number of indicies and ranges
  if ~isequallen(index, range)
    error('the number of indices must match the number of ranges');
  end
  rows = cellfun(@isrow, range);
  range(rows) = cellfun(@transpose, range(rows), 'UniformOutput', false);
  range = cell2sym(range);
  %% return the interative symsum
  % build the symsum string
  n = length(index);
  str = [repmat('sum(', 1, n) '%s,' repmat('%s=%s..%s),', 1, n)];
  str(end) = [];
  % place the arguments in the symsum string
  args = array2cellsymstr(g);
  index = array2cellsymstr(index);
  range = array2cellsymstr(range);
  for k = n:-1:1
    args = [args; index(k); range(:,k)];
  end
  str = sprintf(str, args{:});
  % convert to symbolic
  args = argnames(sym(g));
  args(ismember(args, index)) = [];
  if ~isempty(args)
    f(args) = Str2sym(str);
  else    
    f = Str2sym(str);
  end
