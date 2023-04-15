function colnames = colvar(t, varargin)
  % ------------------------------------------
  % - the colon operator for the
  %   column variables of a table
  % - uses strings to represent the placement
  %   of certain column variables in the table
  % ------------------------------------------
  
  %% check the input arguments
  % check the table argument
  narginchk(1,4);
  if ~istabular(t)
    error('''t'' must be a table or timetable');
  end
  colnames = t.Properties.VariableNames;
  % compute the column strings and increment value
  if nargin == 1 
    return;
  elseif nargin == 2
    col_strings = [varargin varargin];
    inc = 1;
  elseif nargin == 3
    col_strings = varargin;
    inc = 1;
  else
    col_strings = varargin([1 3]);
    inc = varargin{2};
  end
  % check the column strings and increment value
  func = @(arg) isTextScalar(arg, ["char" "string" "cell of char"]);
  TextScalars = cellfun(func, col_strings);
  ints = cellfun(@isintscalar, col_strings);
  infs = cellfun(@isinfscalar, col_strings);
  if ~all(TextScalars | ints | infs)
    str = stack('column variables must be', ...
                'any one of these:', ...
                '-----------------', ...
                '1.) strings', ...
                '2.) integers', ...
                '3.) infs');
    error(str);
  end
  if ~isintscalar(inc)
    error('increment value must be an integer');
  end  
  % account for any special column string values
  mask = ints | infs;
  if ~isempty(colnames)
    ncols = length(colnames);
    ind = [col_strings{mask}];
    ind(ind < 1) = 1;
    ind(ind > ncols) = ncols;
    col_strings(mask) = colnames(ind);
  else    
    col_strings(mask) = cellfun(@num2str, col_strings(mask), ...
                                'UniformOutput', false);
  end
  %% return the column variable names
  if ~all(iscolvar(t, col_strings{:}))
    str = stack('variables ''%s'' and/or ''%s''', ...
                [blanks(9) 'are not found in the table''s'], ...
                [blanks(9) 'column variable names']);
    warning(str, col_strings{:});
  end  
  start = find(ismember(colnames, col_strings{1}));
  finish = find(ismember(colnames, col_strings{2}));
  colnames = colnames(start:inc:finish);
