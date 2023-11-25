function [N B K] = node(X)
  
  %% check the input arguments
  syms x E A L;  
  if ~issym(X) || ~all(issymnum(X(:)/L) | issymnum(X(:)))
    error('''X'' must only contain scalar multiples of ''L''');
  end
  if ~iscolumn(X)
    X = X.';
  end
  %% compute the displacement field
  n = length(X);
  Ao = sym('a', [n 1]);
  Qo = sym('q', [n 1]);
  q(x) = sum(Ao.*x.^(0:n-1).');  
  soln = struct2cell(solve(q(X) == Qo, Ao));
  q = collect(subs(q, Ao, soln), Qo);
  %% compute the output matricies
  N = coeffs(q, Qo(n:-1:1)).';
  B = diff(N);
  if isnumeric(X)
    limits = [min(X) max(X)];
  else
    limits = L*[min(X/L) max(X/L)];
  end
  K = E*A*int(B*B.', limits);