function [tbl Ke K] = Beam(F, bound, connect, E, I, L)
  %% check the input arguments
  [nn ncol.F] = size(F);
  [ne ncol.connect] = size(connect);
  if ~isnumeric(F) || ~isnumeric(bound) || ~isnumeric(connect)
    error('''F'', ''bound'', and ''connect'' must be numeric matrices');
  end
  if ~isequaldim(F, bound)
    str = stack('''F'' and ''bound''', ...
                'must have the same dimensions');
    error(str);
  end  
  if ncol.F ~= 2 || ncol.connect ~= 2
    str = stack('''F'', ''bound'', and ''connect''', ...
                'must have 2 columns');
    error(str);
  end
  if nn ~= ne+1
    str = stack('lengths of ''F'' and ''bound'' must be one greater', ...
                'than the number of rows in ''connect''');
    error(str);
  end
  if ~isnumeric(connect) || ~all(isint(connect(:), 'Type', 'positive'))
    error('''connect'' must be a positive integer matrix');
  end
  if ~isnumeric(connect) || any(connect(:) > 2*ne)
    str = stack('''connect'' must not contain entries', ...
                'greater than the length of ''x'' and ''y''');
    error(str);
  end
  if isscalar(E) && ne ~= 1
    E = E*ones(ne,1);
  end
  if isscalar(I) && ne ~= 1
    I = I*ones(ne,1);
  end
  if isscalar(L) && ne ~= 1
    L = L*ones(ne,1);
  end
  if ~isnumvector(E) || ~isnumvector(I) || ~isnumvector(L)
    error('''E'', ''I'', and ''L'' must be numeric vectors');
  end
  if ~isequallen(E, I, L)
    error('''E'', ''I'', and ''L'' must have the same length');
  end
  if ne ~= length(E)
    str = stack('lengths of ''E'', ''I'', and ''L'' must match', ...
                'the lengths of ''F'' and ''bound''');
    error(str);
  end
  %% modify the input arguments
  F = reshape(F.', [2*nn 1]);
  bound = reshape(bound.', [2*nn 1]);
  if ~iscolumn(E)  
    E = E.';
  end
  if ~iscolumn(I)
    I = I.';    
  end
  if ~iscolumn(L)
    L = L.';
  end
  %% calculate the stiffness matrix
  EIL = E.*I./L.^3;
  [Ke K] = deal(cell(ne,1)); 
  K(:) = {zeros(2*nn)};
  for k = 1:ne
    % element stiffness matrix
    Ke{k} = EIL(k)*[12     6*L(k)   -12     6*L(k); ...
                    6*L(k) 4*L(k)^2 -6*L(k) 2*L(k)^2; ...
                   -12    -6*L(k)    12    -6*L(k); ...
                    6*L(k) 2*L(k)^2 -6*L(k) 4*L(k)^2];    
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
  Qi = Kr^-1*Fr;
  Q = zeros(2*nn,1);
  Q(b) = bound(b);
  Q(i) = Qi; 
  %% solve for the reactions
  Rb = K(b,:)*Q-F(b);
  R = zeros(2*nn,1);
  R(b) = Rb; 
  %% construct the element table
  node = (1:nn).';
  element = (1:ne).'; 
  F = reshape(F, [2 nn]).';
  Q = reshape(Q, [2 nn]).';
  R = reshape(R, [2 nn]).';
  tbl.n = table(node, F, Q, R);
  tbl.e = table(element, connect, E, I, L);  