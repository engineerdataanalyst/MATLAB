function a = branches2piecewise(expr, cond)
  % ---------------------------
  % - converts the branches
  %   to a piecewise expression
  % ---------------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    expr {mustBeA(expr, ["numeric" "sym" "cell"])};
    cond {mustBeA(cond, ["numeric" "sym" "cell"])};
  end
  % check the argument dimensions
  if ~isVector(expr) || ~isVector(cond)
    error('input arguments must be vectors');
  end
  if ~isequallen(expr, cond)
    error('input arguments must have the same lengths');
  end
  %% compute the symbolic function arguments
  if issymfun(expr)
    args = argnames(expr);
  elseif issymfun(cond)
    args = argnames(cond);
  else
    args = sym.empty;
  end
  %% convert non-cell array arguments to cell arrays
  if ~iscell(expr)
    expr = array2cellsym(expr);
  end
  if ~iscell(cond)
    cond = array2cellsym(cond);
  end
  %% compute the piecewise expression
  pw_args = [cond(:) expr(:)].';
  a = piecewise(pw_args{:});
  if ~isempty(args)
    a(args) = a;
  end
