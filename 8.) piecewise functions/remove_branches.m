function a = remove_branches(a, num)
  % ------------------------
  % - removes branches from
  %   a piecewise expression
  % ------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    num (:,1) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_num(a);
  end
  % check the symbolic array
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  % check the branch permutation argument
  if ~all(ismember(num, 1:numBranches(a)))
    str = stack('''num'' must contain numbers', ...
                'that do not exceed', ...
                'the number of branches of ''a'' (%d)');
    error(str, numBranches(a));
  end
  %% remove the piecewise branches
  [expr cond] = branches(a);
  loc = ~ismember((1:numBranches(a)).', num);
  if any(loc)
    pw = branches2piecewise(expr(loc), cond(loc));
  else
    pw = sym.empty;
  end
  if issymfun(a)
    a(argnames(a)) = pw;
  else
    a = pw;
  end
end
% =
function perm = default_num(a)
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
