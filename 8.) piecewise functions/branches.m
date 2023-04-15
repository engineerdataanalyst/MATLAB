function [expr cond] = branches(a)
  % ---------------------------
  % - returns the branches
  %   of a piecewise expression
  % ---------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    a sym;
  end
  % check the symbolic array
  if issymfun(a)
    a = formula(a);
  end
  %% compute the branches for empty arrays
  if isempty(a)
    expr = a;
    cond = symtrue;
    return;
  end
  %% compute the branches for non-piecewise expressions
  [expr cond] = deal(cell(size(a)));
  pws = ispiecewise(a);
  for k = find(~pws(:)).'
    expr{k} = {a(k)};
    cond{k} = {symtrue};
  end
  %% compute the branches for piecewise expressions
  uniform = {'UniformOutput' false};
  for k = find(pws(:)).'
    a_children = children(a(k));
    expr{k} = cellfun(@array2sym, a_children(:,1), uniform{:});
    cond{k} = cellfun(@array2sym, a_children(:,2), uniform{:});
  end
  %% modify the branches to a more convenient type
  if isscalar(a)
    expr = expr{1};
    cond = cond{1};
  end
