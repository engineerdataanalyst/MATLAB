function Pretty(a, num, options)
  % ---------------------------
  % - a slight variation of
  %   the pretty function
  % - will pretty print a
  %   branch of a piecewise
  %   expression in a
  %   column vector format
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    num (1,1) double {mustBeInteger, mustBePositive};
  end
  arguments
    options.ShowConditions (1,1) logical = true;
  end
  ShowConditions = options.ShowConditions;
  % check the symbolic array
  narginchk(1,3);
  if ~ispiecewisescalar(a)
    error('''a'' must be a piecewise scalar array');
  end
  % check the branch numbers
  if nargin == 1
    num = {1};
  end
  if ~ismember(num{1}, 1:numBranches(a))
    str = stack('first ''num'' must not exceed', ...
                'the number of branches of ''a'' (%d)');
    error(str, numBranches(a));
  elseif nargin == 3
    a_child = children(expression(a, num{1}), 1);
    if ~ismember(num{2}, 1:numBranches(a_child))
      str = stack('second ''num'' must not exceed', ...
                  'the number of branches of', ...
                  'the first child of ''a'' (%d)');
      error(str, numBranches(a_child));
    end
  end
  %% pretty print the piecewise branch
  if nargin <= 2
    expr = expression(a, num{1});
    if ShowConditions
      cond = condition(a, num{1});
    else
      cond = sym.empty;
    end
  else
    expr = expression(a_child, num{2});
    if ShowConditions
      cond = [condition(a, num{1}); condition(a_child, num{2})];
    else
      cond = sym.empty;
    end
  end
  pretty([cond; expr]);
