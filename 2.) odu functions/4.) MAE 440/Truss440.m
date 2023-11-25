  function [tbl Le Ke K] = Truss440(xy, F, bound, connect, E, A)
  % -------------------------
  % - solves the truss using
  %   finite element analysis
  % -------------------------

  %% check the input arguments
  [nn ncol.xy] = size(xy);
  [ne ncol.connect] = size(connect);
  if ~isnumeric(xy) || ~isnumeric(F) || ~isnumeric(bound)
    error('''xy'', ''F'', and ''bound'' must be numeric matrices');
  end
  if ~isequaldim(xy, F, bound)
    error('''xy'', ''F'', and ''bound'' must have the same dimensions');
  end
  if ncol.xy ~= 2 || ncol.connect ~= 2
    str = stack('''xy'', ''F'', ''bound'', and ''connect''', ...
      'must have 2 columns');
    error(str);
  end
  if ~isnumeric(connect) || ~all(isint(connect(:), 'Type', 'positive'))
    error('''connect'' must be a positive integer matrix');
  end
  if ~isnumeric(connect) || any(connect(:) > nn)
    str = stack('''connect'' must not contain entries', ...
      'greater than the number of rows of ''xy''');
    error(str);
  end
  if isscalar(E) && ne ~= 1
    E = E*ones(ne,1);
  end
  if isscalar(A) && ne ~= 1
    A = A*ones(ne,1);
  end
  if ~isnumvector(E) || ~isnumvector(A)
    error('''E'' and ''A'' must be numeric vectors');
  end
  if ~isequallen(E, A)
    error('''E'' and ''A'' must have the same length');
  end
  if ne ~= length(E)
    str = stack('lengths of ''E'' and ''A'' must match', ...
      'the number of rows in ''connect''');
    error(str);
  end
  %% modify the input arguments
  F = reshape(F.', [2*nn 1]);
  bound = reshape(bound.', [2*nn 1]);
  if ~iscolumn(E)
    E = E.';
  end
  if ~iscolumn(A)
    A = A.';
  end
  %% calculate the stiffness matrix
  [x y] = deal(xy(:,1), xy(:,2));
  [le l m] = deal(zeros(ne,1));
  [Le Ke K] = deal(cell(ne,1));
  K(:) = {zeros(2*nn)};
  for k = 1:ne
    % element stiffness matrix
    [xi yi xj yj] = deal(x(connect(k,1)), y(connect(k,1)), ...
                         x(connect(k,2)), y(connect(k,2)));
    le(k) = sqrt((xi-xj)^2+(yi-yj)^2);
    l(k) = -(xi-xj)/le(k);
    m(k) = -(yi-yj)/le(k);
    Le{k} = [l(k) m(k) 0 0; 0 0 l(k) m(k)];
    Ke{k} = E(k)*A(k)/le(k)*[1 -1; -1 1];
    Ke{k} = Le{k}.'*Ke{k}*Le{k};
    % assembled stiffness matrix
    c = [2*connect(k,1)-1 2*connect(k,1) ...
      2*connect(k,2)-1 2*connect(k,2)];
    for p = 1:4
      for r = 1:4
        K{k}(c(p),c(r)) = Ke{k}(p,r);
      end
    end
  end
  K = sum(cat(3,K{:}),3);
  %% calculate the reduced matricies
  b = ~isnan(bound);
  i = isnan(bound);
  Kr = K(i,i);
  Fr = F(i)-K(i,b)*bound(b);
  %% solve for the displacement field
  QI = Kr^-1*Fr;
  Q = zeros(2*nn,1);
  Q(b) = bound(b);
  Q(i) = QI;
  %% solve for the reactions
  RB = K(b,:)*Q-F(b);
  R = zeros(2*nn,1);
  R(b) = RB;
  %% solve for the stresses
  sigma = zeros(ne,1);
  for k = 1:ne
    c = [2*connect(k,1)-1 2*connect(k,1) ...
         2*connect(k,2)-1 2*connect(k,2)];
    sigma(k) = E(k)/le(k)*[-1 1]*Le{k}*Q(c);
  end
  %% construct the element table
  node = (1:nn).';
  element = (1:ne).';
  F = reshape(F, [2 nn]).';
  Q = reshape(Q, [2 nn]).';
  R = reshape(R, [2 nn]).';
  tbl.n = table(node, xy, F, Q, R);
  tbl.e = table(element, connect, E, A, le, l, m, sigma);