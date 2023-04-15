function a = shuffle_branches(a)
  % ---------------------------
  % - shuffles the branches
  %   of a piecewise expression
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  % check the symbolic array
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  %% shuffle the piecewise branches
  a = order_branches(a, randperm(numBranches(a)));
