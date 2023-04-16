function [eqn type] = plane_eqn(P, Q, R, vars)
  % ------------------------------------
  % - computes the equation of a plane
  %   passing through three given points
  % ------------------------------------
  
  %% check the input arguments
  % check the points
  narginchk(3,4);
  if (~isnumvector(P, 'Len', 3) && ~issymvector(P, 'Len', 3)) || ...
     (~isnumvector(Q, 'Len', 3) && ~issymvector(Q, 'Len', 3)) || ...
     (~isnumvector(R, 'Len', 3) && ~issymvector(R, 'Len', 3))
    str = stack('first 3 arguments must be', ...
                'numeric or symbolic vectors of length 3');
    error(str);
  end
  P = sym(P);
  Q = sym(Q);
  R = sym(R);
  if ~issymcol(P)
    P = P.';
  end
  if ~issymcol(Q)
    Q = Q.';
  end
  if ~issymcol(R)
    R = R.';
  end
  % check the symbolic variables
  point_vars = symvar([P Q R]);
  Vars2Exclude = point_vars;
  if nargin == 3
    vars = sym.zeros(1,2);
    if ~ismember(sym('x'), Vars2Exclude)
      vars(1) = sym('x');
    else
      [vars(1) Vars2Exclude] = randsym('Vars2Exclude', Vars2Exclude);
    end
    if ~ismember(sym('y'), Vars2Exclude)
      vars(2) = sym('y');
    else
      [vars(2) Vars2Exclude] = randsym('Vars2Exclude', Vars2Exclude);
    end
  end
  if ~issymvarvector(vars, 'Len', 2)
    str = stack('last argument must be', ...
                'a symbolic vector of length 2', ...
                'containing symbolic variables');
    error(str);
  end
  vars = formula(vars);
  if ~isrow(vars)
    vars = vars.';
  end
  % check for invalid points
  if any(ismember(vars, point_vars))
    vars = sym2cell(vars);
    str = stack('the 3 points must not contain', ...
                'any one of these variables:', ...
                '---------------------------', ...
                '1.) ''%s''', ...
                '2.) ''%s''');
    error(str, vars{:});
  end  
  %% compute the equation of the plane
  vars = [vars randsym('Vars2Exclude', Vars2Exclude)];
  n = formula(cross(Q-P, R-P));
  r = vars.'-P;
  if isAlways(n(3) ~= 0, 'Unknown', 'false')
    % solve for z
    eqn(vars(1:2)) = solve(Dot(n, r) == 0, vars(3));
    type = 'z = f(x,y)';
  elseif isAlways(n(2) ~= 0, 'Unknown', 'false')
    % solve for y
    eqn(vars(1)) = solve(Dot(n, r) == 0, vars(2));
    type = 'y = f(x)';
  elseif isAlways(n(1) ~= 0, 'Unknown', 'false')
    % solve for x
    eqn = solve(Dot(n, r) == 0, vars(1));
    type = 'x = constant';
  else
    % undefined equation
    eqn = sym(nan);
    type = 'undefined equation';
  end
