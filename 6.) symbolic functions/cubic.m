function soln = cubic(a, b, c, d, x)
  % ------------------------------
  % - computes the solution to the
  %   cubic polynomial equation:
  %   a*x^3+b*x^2+c*x+d == 0
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a {mustBeA(a, ["numeric" "sym"])} = sym('a');
    b {mustBeA(b, ["numeric" "sym"])} = sym('b');
    c {mustBeA(c, ["numeric" "sym"])} = sym('c');
    d {mustBeA(d, ["numeric" "sym"])} = sym('d');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {a b c d x};  
  if ~compatible_dims(args{:})
    error('input arguments must have compatible dimensions');
  end
  % check the polynomial variable
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  end
  %% compute the solution to the cubic polynomial equation
  persistent S S_vars;
  if isempty(S)
    Dim = [1 5];
    Vars2Exclude = symvar([a b c d x]);
    S_vars = randsym(Dim, 'Vars2Exclude', Vars2Exclude);
    S_vars_cell = num2cell(S_vars);
    [A B C D X] = deal(S_vars_cell{:});
    S = sym.zeros;
    S(A, B, C, D) = solve(A*X^3+B*X^2+C*X+D == 0, X, 'MaxDegree', 3);
  end
  soln = S(a, b, c, d);
  if all(cellfun(@isnumeric, args(1:end-1)))
    if iscell(soln)
      soln = cellfun(@double, soln, 'UniformOutput', false);
    else
      soln = double(soln);
    end
  end
