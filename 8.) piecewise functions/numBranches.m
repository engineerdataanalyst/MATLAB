function num = numBranches(a, branch_num)
  % --------------------------------
  % - returns the number of branches
  %   in a piecewise expression
  % --------------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    a sym;
    branch_num (1,1) double {mustBeInteger, mustBePositive} = 1;
  end
  % check the symbolic array
  if issymfun(a)
    a = formula(a);
  end
  % check the branch numbers
  if (nargin == 2) && ~ismember(branch_num, 1:numBranches(a))
    str = stack('''branch_num'' must not exceed', ...
                'the number of branches of ''a'' (%d)');
    error(str, numBranches(a));
  end
  %% compute the number of branches
  if isempty(a)
    num = 0;
  else
    num = zeros(size(a));
  end
  for k = find(ispiecewise(a(:))).'
    if nargin == 2
      a(k) = children(expression(a, branch_num), 1);
      if ~ispiecewise(a(k))
        continue;
      end
    end
    num(k) = feval(symengine, 'piecewise::numberOfBranches', a(k));
  end
