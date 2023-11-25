function [tbl Ae Be De Ke K] = Cst(xy, F, bound, connect, E, t, nu)
  %% check the input arguments
  [nn ncol.xy] = size(xy);
  [ne ncol.connect] = size(connect);
  if ~isnumeric(xy) || ~isnumeric(F) || ~isnumeric(bound)
    error('''xy'', ''F'', and ''bound'' must be numeric matrices');
  end
  if ~isequaldim(xy, F, bound)
    error('''xy'', ''F'', and ''bound'' must have the same dimensions');
  end  
  if ncol.xy ~= 2
    str = stack('''xy'', ''F'', and ''bound''', ...
                'must have 2 columns');
    error(str);
  end
  if ncol.connect ~= 3
    error('''connect'' must have 3 columns');
  end
  if ~isnumeric(connect) || ~all(isint(connect(:), 'Type', 'positive'))
    error('''connect'' must be a positive integer matrix');
  end
  if ~isnumeric(connect) || any(connect(:) > nn)
    str = stack('''connect'' must not contain entries', ...
                'greater than the length of ''x'' and ''y''');
    error(str);
  end
  if isscalar(E) && ne ~= 1
    E = E*ones(ne,1);
  end
  if isscalar(t) && ne ~= 1
    t = t*ones(ne,1);
  end
  if ~isnumvector(E) || ~isnumvector(t)
    error('''E'' and ''A'' must be numeric vectors');
  end
  if ~isequallen(E, t)
    error('''E'' and ''A'' must have the same length');
  end
  if ne ~= length(E)
    str = stack('lengths of ''E'' and ''A'' must match', ...
                'the number of rows in ''connect''');
    error(str);
  end
  if ~isnumscalar(nu)
    error('''nu'' must be a numeric scalar');
  end
  %% modify the input arguments
  F = reshape(F.', [2*nn 1]);
  bound = reshape(bound.', [2*nn 1]);
  if ~iscolumn(E)  
    E = E.';
  end
  if ~iscolumn(t)
    t = t.';    
  end
  %% calculate the stiffness matrix  
  [x y Ae] = deal(xy(:,1), xy(:,2), zeros(ne,1));  
  [Be De Ke K] = deal(cell(ne,1)); 
  K(:) = {zeros(2*nn)};
  for k = 1:ne
    % element stiffness matrix
    % ----------------------------------
    [xi yi xj yj xk yk] = deal(x(connect(k,1)), y(connect(k,1)), ...
                               x(connect(k,2)), y(connect(k,2)), ...
                               x(connect(k,3)), y(connect(k,3)));
    % ----------------------------------
    Ae(k) = 1/2*det([1 xi yi; ...
                     1 xj yj; ...
                     1 xk yk]);
    % ----------------------------------
    yjk = yj-yk;
    yki = yk-yi;
    yij = yi-yj;
    xkj = xk-xj;
    xik = xi-xk;
    xji = xj-xi;
    % ----------------------------------
    Be{k} = 1/(2*Ae(k))*[yjk 0   yki 0   yij 0; ...
                         0   xkj 0   xik 0   xji; ...
                         xkj yjk xik yki xji yij];
    % ----------------------------------
    De{k} = E(k)/(1-nu^2)*[1  nu 0; ...
                           nu 1  0; ...
                           0  0  (1-nu)/2];             
    % ----------------------------------
    Ke{k} = t(k)*abs(Ae(k))*Be{k}.'*De{k}*Be{k};
    % assembled stiffness matrix   
    c = [2*connect(k,1)-1 2*connect(k,1) ...
         2*connect(k,2)-1 2*connect(k,2) ...
         2*connect(k,3)-1 2*connect(k,3)];
    for p = 1:6
      for r = 1:6
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
  %% solve for the stresses and strains
  [strain stress] = deal(zeros(ne,3));
  for k = 1:ne
    c = [2*connect(k,1)-1 2*connect(k,1) ...
         2*connect(k,2)-1 2*connect(k,2) ...
         2*connect(k,3)-1 2*connect(k,3)]; 
    strain(k,:) = Be{k}*Q(c);
    stress(k,:) = De{k}*Be{k}*Q(c);
  end
  %% construct the element table
  node = (1:nn).';
  element = (1:ne).'; 
  F = reshape(F, [2 nn]).';
  Q = reshape(Q, [2 nn]).';
  R = reshape(R, [2 nn]).';
  tbl.n = table(node, xy, F, Q, R);  
  tbl.e = table(element, connect, E, t, strain, stress);  