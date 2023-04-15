function a = order_branches(a, perm)
  % ---------------------------
  % - reorders the branches
  %   of a piecewise expression
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    perm (:,1) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_perm(a);
  end
  % check the symbolic array
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  % check the branch permutation argument
  if ~isperm(perm.', 1:numBranches(a))
    str = stack('''perm'' must be a permuation', ...
                'of the number of branches of ''a'' (%d)');
    error(str, numBranches(a));
  end
  %% reorder the piecewise branches
  if isequal(perm.', 1:numBranches(a))
    return;
  elseif issymfun(a)
    args = argnames(a);
  else
    args = sym.empty;
  end
  [expr cond] = branches(a);
  a = branches2piecewise(expr(perm), cond(perm));
  if ~isempty(args)
    a(args) = a;
  end
end
% =
function perm = default_perm(a)
  % ---------------------------------
  % - helper function for determining
  %   the default permuation
  % ---------------------------------
  if ispiecewisescalar(a)
    perm = 1:numBranches(a);
  else
    perm = 1;
  end
end
% =
