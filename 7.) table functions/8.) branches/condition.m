function cond = condition(a, num, options)
  % ------------------------------
  % - returns the condition branch
  %   of a piecewise expression
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    num (:,1) double {mustBeInteger, mustBePositive};
  end
  arguments
    options.ShowNumbers (1,1) logical = false;
  end
  % check the symbolic array
  narginchk(1,3);
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  % compute the default branch numbers
  if nargin == 1
    num = {(1:numBranches(a)).'};
  elseif (nargin >= 2) && isempty(num{1})
    num{1} = (1:numBranches(a)).';
  end
  % check the branch numbers
  if ~all(cellfun(@isunique, num))
    error('''num'' must be unique');
  elseif nargin == 3
    a_child = sym(children(expression(a, num{1}), 1));
    if isempty(num{2})
      error('second ''num'' must not be empty');
    elseif ~all(ispiecewise(a_child))
      str = stack('first child of ''a''', ...
                  'must contain piecewise arrays');
      error(str);
    end
  end
  % check the show numbers flag
  ShowNumbers = options.ShowNumbers;
  %% compute the condition branches
  pw = 'piecewise::condition';
  if nargin <= 2
    cond = repmat({sym.nan}, size(num{1}));
  else
    cond = repmat({sym.nan(size(num{2}))}, size(num{1}));
  end
  num_in_range = num{1}.' <= numBranches(a);
  for k = find(num_in_range)
    if nargin <= 2
      cond{k} = feval(symengine, pw, a, num{1}(k));
      continue;
    end
    num_in_range = num{2}.' <= numBranches(a_child(k));
    for p = find(num_in_range)
      cond{k}(p) = feval(symengine, pw, a_child(k), num{2}(p));
    end
  end
  %% modify the output to a more convenient type
  if iscellscalar(cond, 'Mode', 'values')
    cond = vertcat(cond{:});
  end
  %% add numbers to the output if necessary
  if ShowNumbers
    nums = num{1+u(nargin-3)};
    if iscell(cond)
      func = @(arg) [nums arg];
      cond = cellfun(func, cond, 'UniformOutput', false);
    else
      cond = [nums cond];
    end
  end
