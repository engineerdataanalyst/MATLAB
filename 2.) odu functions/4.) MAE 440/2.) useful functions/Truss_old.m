function [t Le Ke K] = Truss_old(x, y, E, A, connect, F, bound)
  %% check the input arguments  
  if ~isnumvector(x) || ~isnumvector(y) || ...
     ~isnumvector(E) || ~isnumvector(A)
    error('''x'', ''y'', ''E'', and ''A'' must numeric be vectors');
  end
  if ~isequallen(x, y)
    error('''x'', and ''y'' must have the same length');
  end 
  if ~isequallen(E, A)
    error('''E'' and ''A'' must have the same length');
  end
  if ~isnumeric(connect) || ~all(isint(connect(:), 'positive'))
    error('''connect'' must be a positive integer matrix');
  end
  [ne nn] = deal(length(E), length(x));
  dim = size(connect);
  if dim(1) ~= ne
    str = stack('''connect'' must have the same', ...
                'number of rows as ''E'' and ''A''');
    error(str);
  end
  if dim(2) ~= 2
    error('''connect'' must have 2 columns');
  end
  if ~isnumeric(connect) || any(connect(:) > nn)
    str = stack('''connect'' must not contain entries', ...
                'greater than the length of ''x'' and ''y''');
    error(str);
  end
  if ~isnumvector(F, 2*nn) || ~isnumvector(bound, 2*nn) 
    str = stack('''F'' and ''bound'' must be numeric vectors', ...
                'with twice the length of ''x'' and ''y''');
    error(str);
  end
  %% obtain the stiffness matrix
  [le l m] = deal(zeros(ne,1));
  [Le Ke K] = deal(cell(ne,1)); 
  K(:) = {zeros(2*nn)};
  for k = 1:ne
    % element stiffness matrix
    [x1 y1 x2 y2] = deal(x(connect(k,1)), y(connect(k,1)), ...
                         x(connect(k,2)), y(connect(k,2)));
    le(k) = sqrt((x1-x2)^2+(y1-y2)^2);
    l(k) = -(x1-x2)/le(k);
    m(k) = -(y1-y2)/le(k);
    Le{k} = [l(k) m(k) 0 0; 0 0 l(k) m(k)];
    Ke{k} = E(k)*A(k)/le(k)*[1 -1; -1 1];
    Ke{k} = Le{k}.'*Ke{k}*Le{k};
    % assembled stiffness matrix   
    c = [2*connect(k,1)-1 2*connect(k,1) ...
         2*connect(k,2)-1 2*connect(k,2)];
    for p = 1:4
      for t = 1:4
        K{k}(c(p),c(t)) = Ke{k}(p,t);
      end
    end  
  end
  K = sum(cat(3,K{:}),3);  
  %% solve for the displacement field
  B = ~isnan(bound);
  I = isnan(bound);
  Kr = K(I,I);
  Fr = F(I)-K(I,B)*bound(B);
  
  QI = Kr^-1*Fr;
  Q = zeros(2*nn,1);
  Q(B) = bound(B);
  Q(I) = QI;
  
  RB = K(B,:)*Q-F(B);
  R = zeros(2*nn,1);
  R(B) = RB;
  
  sigma = zeros(ne,1);
  for k = 1:ne
    c = [2*connect(k,1)-1 2*connect(k,1) ...
         2*connect(k,2)-1 2*connect(k,2)]; 
    sigma(k) = E(k)/le(k)*[-1 1]*Le{k}*Q(c);
  end
  %% construct the element table
  if ~iscolumn(x)
    x = x.';
  elseif ~iscolumn(y)
    y = y.';
  elseif ~iscolumn(E)
    E = E.';
  elseif ~iscolumn(A)  
    A = A.';
  elseif ~iscolumn(F)
    F = F.';    
  end
  node = (1:nn).';
  element = (1:ne).'; 
  F = reshape(F, [2 nn]).';
  Q = reshape(Q, [2 nn]).';
  R = reshape(R, [2 nn]).';
  t.n = table(node, x, y, F, Q, R);
  t.e = table(element, E, A, connect, le, l, m, sigma);