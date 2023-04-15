function a = Subs(a, old, new)
  % --------------------------
  % - comments for this function
  %   coming soon!!!!!
  % --------------------------
  
  %% check the input arguments
  % check the argument class
  arguments
    a sym;
    old sym;
    new sym;
  end
  %% assign the values to the cell array
  [~, old new] = scalar_expand(a, old, new);
  for k = 1:numel(a)
    a(k) = subs(a(k), old(k), new(k));
  end
