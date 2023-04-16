function answer = cauchy_product(a, ind) 
  % --------------------------------------
  % - computes the Cauchy Product
  %   of a given number of infinite series
  % --------------------------------------
  
  %% check the input arguments
  % check the argument classe
  arguments
    a sym;
    ind sym = arraysymvar(a, 1, 'UseRandomVariables', true);
  end
  % check the argument dimensions
  if ~compatible_dims(a, ind)
    error('input arguments must have compatible dimensions');
  end
  [a ind] = scalar_expand(a, ind);
  % check the summation argument
  a = formula(a);
  if ~isvector(a)
    error('''a'' must be a vector');
  end
  % check the summation index
  ind = formula(ind);
  if ~issymvarvector(ind)
    error('''ind'' must be a vector of symbolic variables');
  end
  %% compute the Cauchy Product ranges
  if ~iscolumn(a)
    a = a.';
  end
  k = randsym(size(a), 'Vars2Exclude', symvar(a), ...
                       'Defaults', sym('k', size(a)));
  range = [zeros(size(k)) [inf; k(1:end-1)]];
  range = mat2cell(range, ones(size(a)), 2);
  %% compute the Cauchy Product terms
  if ~iscolumn(ind)
    ind = ind.';
  end
  sublist = ind;
  subvals = [k(1:end-1)-k(2:end); k(end)];
  a = arraysubs(a, sublist, subvals);
  %% compute the Cauchy product
  answer = itsymsum(prod(a), k, range{:});
