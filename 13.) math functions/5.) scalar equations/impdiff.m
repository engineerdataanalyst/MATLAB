function answer = impdiff(eqn, args, options)
  % ----------------------------------
  % - computes the implicit derivative
  %   of y with respect to x
  % ----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    eqn {mustBeA(eqn, 'sym')};
    args.Vars = symvar(eqn, 2);
    args.Order (1,1) double {mustBeInteger, mustBePositive} = 1;
    options.IgnoreAnalyticConstraints;
    options.IgnoreProperties;
    options.PrincipalValue;
    options.Real;
    options.ReturnConditions;
    options.MaxDegree;
  end
  % check the equation
  if ~issymscalar(eqn)
    error('''eqn'' must be a symbolic scalar');
  end
  % check the variables
  Vars = args.Vars;
  if ~issymvarvector(Vars, 'Len', 2)
    str = stack('''vars'' must be a', ...
                'symbolic vector of length two', ...
                'containing variables');
    error(str);
  end
  % check the order
  Order = args.Order;
  % check the solving options
  options = namedargs2cell(options);
  %% compute the dy variable
  Vars2Exclude = symvar(eqn);
  [x y] = deal(Vars(1), Vars(2));
  [yfun Vars2Exclude] = randsym('Vars2Exclude', Vars2Exclude);
  yfun = Str2sym([char(yfun) '(' char(x) ')']);
  dyfun = diff(yfun, x);
  dy = randsym('Vars2Exclude', Vars2Exclude);  
  %% compute the implicit derivative
  IAC = {'IgnoreAnalyticConstraints' true};
  answer = eqn;
  for k = 1:Order
    answer = subs(answer, y, yfun);
    answer = diff(answer, x);
    if k == 1     
      answer = subs(answer, [yfun dyfun], [y dy]);
      answer = solve(answer, dy, options{:});
      dy = subs(answer, y, yfun);
    else      
      answer = subs(answer, dyfun, dy);
      answer = subs(answer, yfun, y);
    end
  end
  answer = simplify(answer, IAC{:});
  %% convert the output to the correct type
  if issymfun(eqn)
    answer(argnames(eqn)) = answer;
  end
