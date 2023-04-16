function varargout = gramschmidt(varargin)
  % -----------------------------------
  % - orthonormalizes a set of vectors
  %   by using the Gram-Schmidt process
  % -----------------------------------

  %% check the input arguments
  func = {@(arg) isnumvector(arg, 'CheckEmpty', true);
          @(arg) issymvector(arg, 'CheckEmtpy', true)};
  num_vectors = cellfun(func{1}, varargin);
  sym_vectors = cellfun(func{2}, varargin);
  if ~all(num_vectors | sym_vectors)
    str = stack('input arguments must be', ...
                'numeric or symbolic vectors');
    error(str);
  end
  %% do the Graham-Schmidt process
  varargout = varargin;
  for k = 1:nargin
    for p = 1:k-1
      varargout{k} = varargout{k}-proj(varargout{p}, varargout{k});
    end
    varargout{k} = unit_vector(varargout{k});
  end
