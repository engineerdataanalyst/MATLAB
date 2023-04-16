function ztan = tplane_eqn(zfun, x0, y0, vars)
  % ----------------------------------------
  % - computes the equation of a plane
  %   tangent to a function at a given point
  % ----------------------------------------
  
  %% check the input arguments
  % check the points
  narginchk(3,4);
  if (~isnumscalar(zfun) && ~issymscalar(zfun)) || ...
     (~isnumscalar(x0) && ~issymvector(x0)) || ...
     (~isnumvector(y0) && ~issymvector(y0))
    str = stack('first 3 arguments must be', ...
                'numeric or symbolic scalars');
    error(str);
  end
  x0 = formula(sym(x0));
  y0 = formula(sym(y0));
  zfun = sym(zfun);
  % check the symbolic variables
  point_vars = symvar([x0 y0]);
  Vars2Exclude = point_vars;
  if nargin == 3 && issymnum(zfun)
    vars = [sym('x') sym('y')];
  elseif nargin == 3
    vars = symvar(zfun, 2);
  end
  if ~issymvarvector(vars, 2)
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
  zfun_vars = symvar(zfun);
  if any(ismember(vars, point_vars))
    vars = sym2cell(vars);
    str = stack('the points must not contain', ...
                'any one of these variables:', ...
                '---------------------------', ...
                '1.) ''%s''', ...
                '2.) ''%s''');
    error(str, vars{:});
  end
  Vars2Exclude = symvar([Vars2Exclude zfun_vars]);
  %% compute the equation of the tangent plane
  if ~issymfun(zfun)
    zfun(vars) = zfun;
  end
  vars = [vars randsym('Vars2Exclude', Vars2Exclude)];  
  n(vars(1:2)) = gradient(vars(3)-zfun, vars).';
  r = vars-[x0 y0 zfun(x0, y0)];
  ztan(vars(1:2)) = solve(Dot(n(x0,y0), r) == 0, vars(3));
