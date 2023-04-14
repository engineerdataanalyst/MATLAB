function s = merge_structs(s)
  % ----------------------------
  % - merges the fieldnames of
  %   the input struct arguments
  %   into one new struct
  % ----------------------------
  
  %% check the input argument
  % check the argument class
  arguments (Repeating)
    s struct;
  end
  % check the argument dimensions
  if ~isequaldim(s{:})
    error('the structure arrays must have the same dimensions');
  end
  %% merge the structure arrays
  uniform = {'UniformOutput' false};
  Cell = cellfun(@struct2cell, s, uniform{:});
  Fields = cellfun(@fieldnames, s, uniform{:});
  s = cell2struct(vertcat(Cell{:}), vertcat(Fields{:}));
