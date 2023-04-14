function vars = arraysymvar(a, n, options)
  % ---------------------------
  % - calls the symvar function
  %   on each element of a
  %   symbolic array
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    n sym = inf;
    options.UseRandomVariables (1,1) logical = false;
  end
  % check the argument dimensions
  if ~compatible_dims(a, n)
    error('input arguments must have compatible dimensions');
  end
  [a n] = scalar_expand(formula(a), formula(n));
  % check the random variable option
  UseRandomVariables = options.UseRandomVariables;
  %% call the symvar function
  try
    uniform = {'UniformOutput' false};
    func = @(A, N) symvar(A, N);
    symnums = issymnum(a);
    if UseRandomVariables
      vars = randsym(size(a), 'Vars2Exclude', symvar(a));
    else
      vars = sym.nan(size(a));
    end
    [vars a n] = deal(num2cell(vars), num2cell(a), num2cell(n));
    vars(~symnums) = cellfun(func, a(~symnums), n(~symnums), uniform{:});
    if iscellscalar(vars, 'Mode', 'cell or values')
      vars = sym(vars);
    end
  catch Error
    throw(Error);
  end
