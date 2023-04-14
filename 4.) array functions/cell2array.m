function anew = cell2array(a, ind)
  % ------------------------------------
  % - grabs each element of a cell array
  %   at a specified index or subscript
  %   and concatenates them into a
  %   homogeneous array
  % ------------------------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    a cell;
  end
  arguments (Repeating)   
    ind {mustBeNumericOrLogical};
  end
  % check the argument dimensions
  if ~compatible_dims(a{:})
    str = stack('the contents of the cell array', ...
                'must have compatible dimensions');
    error(str);
  end
  [a{:}] = scalar_expand(a{:});
  % check the cell array indices
  if isempty(ind)
    error('there must be at least 1 cell array index');
  end
  %% compute the concatenated array
  uniform = {'UniformOutput' false};
  if isempty(a)
    anew = a;
  else
    func = @(arg) index_fun(arg, ind);
    anew = cellfun(func, a, uniform{:});
  end
end
% =
function arg = index_fun(arg, ind)
  % ---------------------
  % - helper function for
  %   indexing into the
  %   cell array
  % ---------------------
  if ~isEmpty(arg)
    arg = index(arg, ind{:});
  end
end
