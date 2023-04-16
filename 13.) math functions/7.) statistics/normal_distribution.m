function [P f] = normal_distribution(x, mu, sigma)
  % ------------------------------------------
  % - computes the cumulative probability (P)
  %   and the probability density function (f)
  %   from -inf to a queried value (x)
  %   and the probability function (f)
  %   of a normal distribution
  %   with a mean (mu) and
  %   standard deviation (sigma)
  % ------------------------------------------

  %% check the input arguments
  % check the argument classes
  arguments
    x {mustBeA(x, ["numeric" "sym"])};
    mu {mustBeA(mu, ["numeric" "sym"])} = 0;
    sigma {mustBeA(sigma, ["numeric" "sym"])} = 1;
  end
  % check the argument dimensions
  if ~compatible_dims(x, mu, sigma)
    error('input argument smust have compatible dimensions');
  end
  % check for invalid function arguments
  if ~isequalargnames(x, mu, sigma, 'CheckSymfunsOnly', true)
    error(message('symbolic:symfun:InputMatch'));
  elseif issymfun(x)
    args = argnames(x);
  else
    args = sym.empty;
  end
  %% compute the normal distribution input variables
  Vars2Exclude = [reshape(x, [], 1); 
                  reshape(mu, [], 1);
                  reshape(sigma, [], 1)];
  Vars2Exclude = symvar(sym(Vars2Exclude));
  Defaults = sym('x');
  var = randsym(Size(x), ...
                'Vars2Exclude', Vars2Exclude, 'Defaults', Defaults);
  %% compute the normal distribution expression
  func = cell(2,1);
  func{1} = @(Arg, Var) symfun(Arg, [Var args]);
  if ~isempty(args)
    func{2} = @(Expr, Var, X) symfun(int(Expr, Var, -inf, X), args);
    flag = false;
  else
    func{2} = @(Expr, Var, X) int(Expr, Var, -inf, X);
    flag = true;
  end
  if ~issym(x) && ~issym(mu) && ~issym(sigma)
    func{2} = @(Arg, Var, X) double(func{2}(Arg, Var, X));
  end
  K1 = 1./(sigma*sqrt(2*sympi));
  K2 = (var-mu)./sigma;
  expr = K1.*exp(-K2.^2/2);
  if issymfun(expr)
    expr = formula(expr);
  end
  %% compute the normal distribution outputs
  if isScalar(x)
    f = func{1}(expr, var);
    P = func{2}(f, var, x);
  else
    f = arrayfun(func{1}, expr, var, 'UniformOutput', false);
    P = arrayfun(func{2}, expr, var, x, 'UniformOutput', flag);
  end
