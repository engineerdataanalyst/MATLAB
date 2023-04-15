function rownames = rowvar(t, varargin)
  % -----------------------------------------
  % - the colon operator for the
  %   row variables of a table
  % - uses strings to represent the placement
  %   of certain row variables in the table
  % -----------------------------------------
  
  %% check the input arguments
  % check the table argument
  narginchk(1,4);
  if ~istabular(t)
    error('''t'' must be a table or timetable');
  end
  rownames = t.Properties.RowNames;
  % compute the row strings and increment value
  if nargin == 1
    return;
  elseif nargin == 2
    row_strings = [varargin varargin];
    inc = 1;
  elseif nargin == 3
    row_strings = varargin;
    inc = 1;
  else
    row_strings = varargin([1 3]);
    inc = varargin{2};
  end
  % check the row strings and increment value
  TextScalars = cellfun(@isTextScalar, row_strings);
  ints = cellfun(@isintscalar, row_strings);
  infs = cellfun(@isinfscalar, row_strings); 
  if ~all(TextScalars | ints | infs)
    str = stack('row variables must be:', ...
                '----------------------', ...
                '1.) strings', ...
                '2.) integers', ...
                '3.) infs');
    error(str);
  end
  if ~isintscalar(inc)
    error('increment value must be an integer');
  end
  % account for any special row string values
  mask = ints | infs;
  if ~isempty(rownames)
    nrows = length(rownames);
    ind = [row_strings{mask}];
    ind(ind < 1) = 1;
    ind(ind > nrows) = nrows;
    row_strings(mask) = rownames(ind);
  else    
    row_strings(mask) = cellfun(@num2str, row_strings(mask), ...
                                'UniformOutput', false);
  end
  %% return the row variable names
  if ~all(isrowvar(t, row_strings{:}))
    str = stack('variables ''%s'' and/or ''%s''', ...
                [blanks(9) 'are not found in the table''s'], ...
                [blanks(9) 'row variable names']);
    warning(str, row_strings{:});
  end  
  start = find(ismember(rownames, row_strings{1}));
  finish = find(ismember(rownames, row_strings{2}));
  rownames = rownames(start:inc:finish);
