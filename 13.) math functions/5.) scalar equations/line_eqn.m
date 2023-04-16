function eqn = line_eqn(P, Q, t)
  % -----------------------------------------
  % - returns the parametric equations
  %   of a line through the points (P and Q),
  %   parametrized by (t)
  % -----------------------------------------
  
  %% compute the point variables
  narginchk(2,3);
  if issym(P)
    P_vars = symvar(P);
  else
    P_vars = [];
  end
  if issym(Q)
    Q_vars = symvar(Q);
  else
    Q_vars = [];
  end
  point_vars = unique([P_vars Q_vars]);
  %% compute the default argument  
  if nargin == 2    
    t = randsym('Vars2Exclude', point_vars, 'Defaults', sym('t'));
  end
  %% check the input arguments
  if (~isnumvector(P) && ~issymvector(P)) || ...
     (~isnumvector(Q) && ~issymvector(Q))
    str = stack('''P'' and ''Q'' must be', ...
                'numeric or symbolic vectors');
    error(str);
  end
  if ~isequallen(P, Q)
    error('''P'' and ''Q'' must have the same lengths');
  end
  if ~issymvarscalar(t)
    error('''t'' must be a symbolic variable scalar');
  end
  if ismember(t, point_vars)
    str = stack('the point variables must not contain', ...
                'the equation variable ''%s''');
    error(str, t);
  end
  %% convert any row vectors to column vectors
  if ~isnumcol(P) && ~issymcol(P)
    P = P.';
  end
  if ~isnumcol(Q) && ~issymcol(Q)
    Q = Q.';
  end
  %% compute the parametric equations
  V = Q-P;
  eqn(t) = P+V*t;  
