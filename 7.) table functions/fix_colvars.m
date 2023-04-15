function t = fix_colvars(t, newvars, default)
  % ------------------------------------
  % - fixes the table's column variables
  % ------------------------------------
  
  %% compute the default arguments
  narginchk(2,3);
  if nargin == 2
    default = 0;
  end
  if isTextScalar(newvars, 'char')
    newvars = {newvars};
  end
  if isTextScalar(default, 'char') || (isrow(default) && ~iscell(default))
    default = {default};
  end  
  if isvector(newvars) && ~isrow(newvars)
    newvars = newvars.';
  end
  if isvector(default) && ~isrow(default)
    default = default.';
  end
  %% check the input arguments
  % check the table
  if ~istabular(t)
    error('''t'' must be a table or timetable');
  end
  % check the newvars type
  if ~isTextVector(newvars, ["char" "string" "cell of char"], ...
                  'CheckEmptyArray', true, 'CheckEmptyText', true)
    str = stack('''newvars'' must be:', ...
                '1.) a string', ...
                '2.) a cell vector of non-empty strings');
    error(str);
  end
  % check the default type
  if ~iscellvector(default)
    error('''default'' must be a cell vector');
  end
  % check the lengths of newvars and default
  if ~isequallen(newvars, default) && ~isscalar(default)
    str = stack('''newvars'' and ''default'' must be', ...
                'cell vectors with the same lengths', ...
                'or the last one can be a row vector');
    error(str);
  end
  % check for a valid default argument
  if ~all(cellfun(@isrow, default))    
    error('third argument must be a row vector of objects');
  end
  %% fix the column variables
  % fix the scalar arguments
  if isscalar(default) && ~isscalar(newvars)
    default = repmat(default, size(newvars)); 
  end
  % save the original table
  old = t;
  % make the lengths  
  newvars_len = length(newvars);
  t_width = width(t);
  t_height = height(t);
  if t_width > newvars_len
    t(:,newvars_len+1:end) = [];
  end
  % construct the appended table
  if t_width > newvars_len
    c = table;
  else
    c = repmat({zeros(t_height,1)}, newvars_len-t_width, 1);
    c = table(c{:});  
  end  
  % modify the appended table's variable names if necessary
  cvars = c.Properties.VariableNames;
  tvars = t.Properties.VariableNames;
  ind = ismember(cvars, tvars);
  while any(ind)
    str = repmat({randchar('Type', 'lower')}, size(cvars(ind)));
    cvars(ind) = cellfun(@horzcat, cvars(ind), str, ...
                         'UniformOutput', false);
    c.Properties.VariableNames = cvars;
    ind = ismember(cvars, tvars);
  end  
  t = [t c];
  % fix the table's column variables
  t.Properties.VariableNames = newvars;
  tvars = t.Properties.VariableNames;
  newtypes = cellfun(@class, default, 'UniformOutput', false);
  default_len = cellfun(@length, default);
  colvar_found = iscolvar(old, tvars{:});
  for k = 1:newvars_len    
    correct_type = isa(t.(tvars{k}), newtypes{k});
    correct_dim = isdim(t.(tvars{k}), [t_height default_len(k)]);
    if ~colvar_found(k) || ~correct_type || ~correct_dim
      t.(tvars{k}) = repmat(default{k}, [t_height 1]);
    else
      t.(tvars{k}) = old.(tvars{k});
    end
  end
