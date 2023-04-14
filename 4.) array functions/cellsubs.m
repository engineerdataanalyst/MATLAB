function a = cellsubs(a, old, new)
  % -------------------------
  % - calls the subs function
  %   on each element of a
  %   cell array
  % -------------------------
  
  %% check the input arguments
  arguments
    a cell;
    old;
    new;
  end
  %% assign the values to the cell array
  try
    func = @(arg) subs(arg, old, new);
    a = cellfun(func, a, 'UniformOutput', false);
  catch Error
    throw(Error);
  end
