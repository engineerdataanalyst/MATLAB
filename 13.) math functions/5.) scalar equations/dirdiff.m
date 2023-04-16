function answer = dirdiff(f, v, varargin)
  % -------------------------------------
  % - computes the directional derivative
  %   of a function (f) in the given
  %   direction of the vector (v)
  % -------------------------------------
  
  %% check the input arguments
  if issymfun(f)
    use_argnames = true;
    args = argnames(f);
    f = formula(f);
  else
    use_argnames = false;
  end
  if ~issymscalar(f)
    error('first argument must be a symbolic scalar');
  end
  if ~isnumvector(v, 'CheckEmpty', true) && ...
     ~issymvector(v, 'CheckEmpty', true)
    str = stack('second argument must be a', ...
                'non-empty numeric or symbolic vector');
    error(str);
  end  
  symvarscalars = cellfun(@issymvarscalar, varargin);
  if ~all(symvarscalars)
    str = stack('third argument and all others that follow', ...
                'must be symbolic variable scalars');
    error(str);
  end
  %% compute the variables
  vars = sym(convert2row(varargin));
  if isempty(vars)
    if use_argnames
      vars = args;
    else
      vars = symvar(f);
    end
  end
  if ~isequallen(v, vars)
    dim = [1 abs(length(v)-length(vars))];
    vars = [vars randsym(dim, 'Vars2Exclude', symvar(f))];
  end
  %% compute the directional derivative
  delf = gradient(f, vars);
  u = unit_vector(v);
  answer = Dot(delf, u);
  if use_argnames
    answer(args) = answer;
  end
