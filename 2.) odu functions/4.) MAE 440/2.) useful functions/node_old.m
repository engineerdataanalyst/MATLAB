function [N B K] = node(n, varargin)
  %% check the input arguments
  args = inputParser;
  args.addParameter('X', sym('x', [n 1]));
  args.addParameter('limits', [1 n]);
  args.parse(varargin{:});
  X = args.Results.X;
  limits = args.Results.limits;
  if ~isnumscalar(n) && ~isssymscalar(n)
    error('''n'' must be a numeric or symbolic scalar');
  end
  if  ~isnumvector(X) && ~issymvector(X)
    error('''x'' must be a numeric or symbolic vector');
  end
  if ~isnumvector(limits, 2) && ~issymvector(limits, 2)
    error('''limits'' must be a numeric or symbolic vector of length 2');
  end
  if n ~= length(X)
    error('''n'' must be equal to the length of ''x''');
  end
  if ~iscolumn(X)
    X = X.';
  end
  %% compute the displacement field
  syms x Eo Ao L;  
  A = sym('a', [n 1]);
  Q = sym('q', [n 1]);
  q(x) = sum(A.*x.^(0:n-1).');  
  soln = struct2cell(solve(q(X) == Q, A));
  q = collect(subs(q, A, soln), Q);
  %% compute the output matricies
  N = coeffs(q, Q(n:-1:1)).';
  B = diff(N);
  K = Eo*Ao*int(B*B.', X(limits));