function a = Magic(n, K)
  % -------------------------------------------
  % - a slight variation of the magic function
  % - will compute the magic square of a matrix
  %   using a general solution
  % -------------------------------------------
  
  %% compute the default argument
  narginchk(1,2);
  if nargin == 1
    K = sym('K');
  end
  %% check the input argument  
  if ~isintscalar(n, 'Type', 'positive')
    str = stack('first argument must be', ...
                'a positive integer scalar');
    error(str);
  end
  if ~isnumscalar(K) && ~issymscalar(K)
    str = stack('second argument must be', ...
                'a numeric or symbolic scalar');
    error(str);
  end
  %% compute the magic square
  if isnumeric(K)
    K = sym(K);
  end
  K_args = argnames(K);
  K_vars = [K_args setdiff(symvar(K), K_args)];
  a = randsym(n, 'Vars2Exclude',K_vars);
  num_eqns = 2*n+2;
  eqn = sym.zeros(num_eqns,1);
  for k = 1:num_eqns
    if k <= n
      eqn(k) = sum(a(k,:)) == K;
    elseif k <= 2*n
      eqn(k) = sum(a(:,k-n)) == K;
    elseif k == num_eqns-1
      eqn(k) = trace(a) == K;
    else
      eqn(k) = trace(fliplr(a)) == K;
    end
  end
  soln = solve(eqn, a, 'ReturnConditions', true);
  a = subs(a, rmfield(soln, {'parameters' 'conditions'}));
  if ~isempty(K_vars) || ~isempty(soln.parameters)
    a([K_vars soln.parameters]) = a;
  end
