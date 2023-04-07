function bool = cellismember(a, b)
  % ----------------------------------------------
  % - a slight variation of the ismember function
  % - will return false for entries
  %   of a cell array that are empty
  %   and return the logical condition
  %   computed by the regular ismember function
  %   for the non-empty entries
  % ----------------------------------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    a cell;
    b;
  end
  %% find the location of the elements in 'a' that are in 'b'
  if isempty(a)
    bool = false;
  else
    emptys = cellfun(@isempty, a);
    bool = false(size(a));
    bool(~emptys) = ismember(a(~emptys), b);
  end
