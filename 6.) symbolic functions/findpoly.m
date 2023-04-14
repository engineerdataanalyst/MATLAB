function [f df d2f point] = findpoly(order, type, coordinate, options)
  % -------------------------------------------------
  % - computes a symbolic polynomial expression
  %   that satisfies a criteria of point requirements
  % -------------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    order (1,1) double {mustBeInteger, mustBeNonnegative};
  end
  arguments (Repeating)
    type ...
    {mustBeTextScalar, ...
     mustBeMemberi(type, ["thru" "cp" "ip"])};
    coordinate sym;
  end
  arguments
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["simplify" ...
                                  "factor" ...
                                  "factor full" ...
                                  "factor complex" ...
                                  "factor real" ...
                                  "simplify fraction" ...
                                  "simplify fraction expand"])} = ...
                                  "simplify";
    options.Var sym = sym('x');
  end
  % check the simplification mode
  Mode = lower(options.Mode);
  % check the polynomial variable
  x = options.Var;
  if ~issymvarscalar(x)
    str = stack('the polynomial variable must be', ...
                'a symbolic variable scalar');
    error(str);
  end
  % check the point requirements
  if isempty(type)
    error('there are no point requirements');
  end
  uniform = {'UniformOutput' false};
  type = string(cellfun(@lower, type, uniform{:}));
  coordinate = cellfun(@formula, coordinate, uniform{:});
  point_vars = sym(cellfun(@symvar, coordinate, uniform{:}));
  if ismember(x, point_vars)
    str = stack('the points must not contain', ...
                'the polynomial variable ''%s''');
    error(str, x);
  end
  %% parse the point requirements
  % equation array
  num_points = length(type);
  eqn = sym.zeros(num_points, 1);
  % symbolic polynomial equation
  dim = [1 order+1];
  Vars2Exclude = [point_vars x];
  coeff = randsym(dim, 'Vars2Exclude', Vars2Exclude);
  f(x) = poly2sym(coeff, x);
  df = diff(f, x);
  d2f = diff(df, x);
  % point table
  point.type = categorical(type).';  
  point.coordinate = cellfun(@array2symstr, coordinate, uniform{:}).';
  point.coordinate = string(point.coordinate);
  point = struct2table(point); 
  for k = 1:length(type)
    if type(k) == "thru"
      if ~isVector(coordinate{k}, 'Len', 2)
        str = stack('for point type ''thru'',', ...
                    'the coordinates must be', ...
                    'vectors of length 2');
        error(str);
      end
      eqn(k) = f(coordinate{k}(1)) == coordinate{k}(2);
    else
      if ~isScalar(coordinate{k})
        str = stack('for point types ''cp'' and ''ip'',', ...
                    'the coordinates must be scalars');
        error(str);
      end
      if type(k) == "cp"
        eqn(k) = df(coordinate{k}) == 0;
      else
        eqn(k) = d2f(coordinate{k}) == 0;
      end
    end
  end
  %% solve for the unknown coefficients
  % compute the solution
  soln = solve(eqn, coeff, 'ReturnConditions', true);
  soln = rmfield(soln, {'parameters' 'conditions'});
  % substitute the solution into the polynomial equation
  f = subs(f, soln);
  df = subs(df, soln);
  d2f = subs(d2f, soln);
  % simplify the polynomial equation
  f = simplify(f, 'IgnoreAnalyticConstraints', true);
  df = simplify(df, 'IgnoreAnalyticConstraints', true);
  d2f = simplify(d2f, 'IgnoreAnalyticConstraints', true);
  switch Mode
    case "factor"
      f = prodfactor(f);
      df = prodfactor(df);
      d2f = prodfactor(d2f);
    case "factor full"
      f = prodfactor(f, 'FactorMode', 'full');
      df = prodfactor(df, 'FactorMode', 'full');
      d2f = prodfactor(d2f, 'FactorMode', 'full');
    case "factor complex"
      f = prodfactor(f, 'FactorMode', 'complex');
      df = prodfactor(df, 'FactorMode', 'complex');
      d2f = prodfactor(d2f, 'FactorMode', 'complex');
    case "factor real"
      f = prodfactor(f, 'FactorMode', 'real');
      df = prodfactor(df, 'FactorMode', 'real');
      d2f = prodfactor(d2f, 'FactorMode', 'real');
    case "simplify fraction"
      f = simplifyFraction(f);
      df = simplifyFraction(df);
      d2f = simplifyFraction(d2f);
    case "simplify fraction expand"
      f = simplifyFraction(f, 'Expand', true);
      df = simplifyFraction(df, 'Expand', true);
      d2f = simplifyFraction(d2f, 'Expand', true);
  end
