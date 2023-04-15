function a = prodfactor(a, varargin)
  % --------------------------
  % - factors a symbolic array
  % --------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    varargin;
  end
  % check for symbolic functions
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  %% factor the symbolic array
  for k = 1:numel(a)
    num_branches = numBranches(a(k));
    if num_branches == 0
      a(k) = prod(factor(a(k), varargin{:}));
      continue;
    end
    [expr cond] = branches(a(k));
    for p = 1:num_branches
      expr{p} = prodfactor(expr{p}, varargin{:});
    end
    a(k) = branches2piecewise(expr, cond);
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    a(args) = a;
  end
