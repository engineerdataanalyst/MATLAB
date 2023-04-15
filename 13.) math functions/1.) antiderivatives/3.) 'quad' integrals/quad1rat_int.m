function [F f tF dF sF cF] = quad1rat_int(n, a, b, c, alpha, beta, x, options)
  % - formula for this integral:
  % ------------------------------------
  %  /
  %  | (alpha*x+beta)*(a*x^2+b*x+c)^n dx
  %  /
  % ------------------------------------
  % - using these methods:
  %   1.) inverse trig/hyperbolic functions
  %   2.) partial fractions
    
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    a sym = sym('a');
    b sym = sym('b');
    c sym = sym('c');
    alpha sym = sym('alpha');
    beta sym = sym('beta');
    x sym = sym('x');
    options.Method ...
    {mustBeText, mustBeMemberi(options.Method, ["one" "two"])};
  end
  % check the argument dimensions
  args = {n a b c alpha beta x};
  if isfield(options, 'Method')
    Method = lower(string(options.Method));
  else
    Method = "all";
  end
  if ~compatible_dims(args{:}, Method)
    error('input arguments must have compatible dimensions');
  end
  % check the integration variable
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  end
  % check the integration method
  if isequal(Method, "all")
    for k = ["one" "two"]
      Args = [args {'Method' k}];
      [F.(k) f.(k) tF.(k) dF.(k) sF.(k) cF.(k)] = quad1rat_int(Args{:});
    end
    return;
  end
  %% compute the integral
  persistent Fp fp dFp;
  if isempty(Fp)
    [Fp fp dFp] = persistent_fun;
  end
  [F f tF dF sF cF] = output_fun(Fp, fp, dFp, args, Method);
end
% =
function [Fp fp dFp] = persistent_fun
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integrals
  % ---------------------------------

  %% integrand
  [n a b c alpha beta x] = deal(sym('n'), ...
                                sym('a'), sym('b'), sym('c'), ...
                                sym('alpha'), sym('beta'), sym('x'));
  fp(n, a, b, c, alpha, beta, x) = (alpha*x+beta)*(a*x^2+b*x+c)^n;
  fp = default_struct('one', 'two', 'Default', fp);
  %% cases
  Disc = disc(a, b, c); % b^2-4*a*c
  cases = [n == 0 | (a == 0 & b == 0);
           a == 0 & b ~= 0;
           a ~= 0 & (Disc == 0);
           a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  [Fp.one Fp.two Diff.one Diff.two] = deal(sym.zeros(size(cases)));
  %% integral calculations
  % ----------------------------
  % case 1: n == 0 | (a == 0 & b == 0)
  Fp.one(1) = alpha*c^n*x^2/2+beta*c^n*x;
  Fp.two(1) = Fp.one(1);
  Diff.one(1) = diff(Fp.one(1));
  Diff.two(1) = diff(Fp.two(1));
  % ----------------------------
  % case 2: a == 0 & b ~= 0
  [Fp.one(2) Diff.one(2)] = a_zero(n, b, c, alpha, beta, x);
  [Fp.two(2) Diff.two(2)] = deal(Fp.one(2), Diff.one(2));
  % ----------------------------
  % case 3: a ~= 0 & (Disc == 0)
  [Fp.one(3) Diff.one(3)] = Disc_zero(n, a, b, alpha, beta, x);
  [Fp.two(3) Diff.two(3)] = deal(Fp.one(3), Diff.one(3));
  % ----------------------------
  % case 4: a ~= 0
  [Fp.one(4) Diff.one(4)] = Disc_not_zero(n, a, b, c, alpha, beta, x);
  [Fp.two(4) Diff.two(4)] = Method_two(Fp.one(4), Diff.one(4), ...
                                       a, b, c, x, Disc);
  % ----------------------------
  %% converting to piecewise
  IAC = {'IgnoreAnalyticConstraints' true};
  K = simplify(simplifyFraction(x+b/(2*a)), IAC{:});
  Args = argnames(fp.one);
  H(Args) = piecewise(a ~= 0 & Disc == 0, ...
                      a^n*(alpha*x+beta)*K^(2*n), fp.one);
  H = simplify(H, IAC{:});
  for k = ["one" "two"]
    Fp.(k)(Args) = branches2piecewise(Fp.(k), cases);
    Diff.(k)(Args) = branches2piecewise(Diff.(k), cases);
    dFp.(k) = @(dFp_args) ...
    simplify(Diff.(k)(dFp_args{:})-H(dFp_args{:}), IAC{:})+...
    fp.(k)(dFp_args{:});
  end
end
% =
function [Fp Diff] = a_zero(n, b, c, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - a == 0
  % --------------------------------
  
  %% integration variables
  IAC = {'IgnoreAnalyticConstraints' true};
  u = sym('u');
  %% u-substitution
  U = b*x+c;
  integrand = (alpha*x+beta)*U^n;
  I = int(integrand, 'Hold', true);
  Iu = changeIntegrationVariable(I, U, u);
  Iu = combine(expand(Iu), 'int');
  Iu = combine(Iu, IAC{:});
  %% fixing the integral
  sublist = children(Iu, 1);
  subvals = sym(children(sublist)).';
  subvals = [subvals(1); sum(subvals(2:3))];
  subvals(2) = simplify(subvals(2), IAC{:});
  subvals = sum(subvals);
  Iu = subs(Iu, sublist, subvals);
  Iu = children(split_body(Iu));
  %% integral calculation
  func = @(arg) int(children(arg, 1));
  Iu = sum(cellfun(func, Iu));
  Iu = order_branches(Iu, [2 1 3]);
  Fp = subs(Iu, u, U);
  %% modifying the integral
  sublist = alpha*U;
  subvals = alpha*b*x;
  Fp = subs(Fp, sublist, subvals);
  Diff = diff(Fp, x);
end
% =
function [Fp Diff] = Disc_zero(n, a, b, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 3:
  % - b^2-4*a*c == 0
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  IAC = {'IgnoreAnalyticConstraints' true};
  u = sym('u');
  %% u-substitution
  integrand = (alpha*x+beta)*(2*a*x+b)^(2*n)/(2^(2*n)*a^n);
  I = int(integrand, 'Hold', true);
  U = 2*a*x+b;
  Iu = changeIntegrationVariable(I, U, u);
  Iu = simplify(Iu, IAC{:});
  Iu = combine(expand(Iu), 'int');
  %% fixing the integral
  sublist = children(Iu, 1);
  subvals = Simplify(sublist, IAC{:});
  subvals = sym(children(subvals));
  subvals = [subvals(1) sum(subvals(2:3))];
  subvals(2) = simplify(subvals(2), IAC{:});
  subvals = sum(subvals);
  Iu = subs(Iu, sublist, subvals);
  Iu = children(split_body(Iu));
  %% integral calculation
  func = @(arg) int(children(arg, 1));
  func = @(arg) Simplify(func(arg), IAC{:});
  Fu = sum(cellfun(func, Iu));
  Fp = subs(Fu, u, U);
  %% modifying the integral
  Fp = SimplifyFraction(Fp);
  K = [2*a*beta-alpha*b; alpha];
  P = sym([1; 2]);
  sublist = [K.*U^(2*n).*U.^P; 1/(a^n*a^2)];
  subvals = combine(sublist, IAC{:});
  Fp = subs(Fp, sublist, subvals);
  Diff = diff(Fp, x);
end
% =
function [Fp Diff] = Disc_not_zero(n, a, b, c, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 3:
  % - b^2-4*a*c ~= 0
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  IAC = {'IgnoreAnalyticConstraints' true};
  [k u] = deal(sym('k'), sym('u'));
  Disc = disc(a, b, c);
  Disc_is_pos = Disc > 0 | ~in(Disc, 'real');
  Disc_is_neg = Disc < 0;
  a_is_pos = a > 0 | ~in(a, 'real');
  a_is_neg = a < 0;
  N = 2*n+2;
  A = sym.zeros(2,1);
  A(1) = x+b/(2*a);
  A(2) = sqrt(-Disc)/(2*a);
  S = heaviside(k-1);
  %% u-subsitution
  integrand = (alpha*x+beta)*(a*x^2+b*x+c)^n;
  I = int(integrand, 'Hold', true);
  U = rhs(isolate(A(1) == A(2)*tan(u), u));
  Iu = changeIntegrationVariable(I, U, u);
  Iu = simplify(Iu, IAC{:});
  %% fixing the integral (part 1)
  sublist = children(findSymType(Iu, 'int'), 1);
  subvals = expand(sublist, 'ArithmeticOnly', true);
  subvals = combine(subvals, IAC{:});
  subvals = Simplify(subvals, 1:2, 'Separate', false);
  Iu = split_body(intsubs(Iu, sublist, subvals));
  %% fixing the integral (part 2)
  Children = sym(children(Iu));
  Loc = ~hasSymType(Children, 'int');
  K = prod(Children(Loc));
  Iu = sum(K*children(Iu/K));
  Iu = combine(factor_constants(Iu), IAC{:});
  %% trig values
  Tan = tan(U);
  Sin = Tan/sqrt(1+Tan^2);
  Cos = 1/sqrt(1+Tan^2);
  Sin = simplify(Sin, IAC{:});
  Cos = simplify(Cos, IAC{:});
  %% integral calculations
  Ints = findSymType(Iu, 'int').';
  Old_Sums = sym.zeros(2,1);
  Old_Sums(1) = sec_int(N, 1, 0, u, Method='two');
  Old_Sums(2) = piecewise(N == 0, -log(cos(u)), ...
                      N ~= 0,  1/(N*cos(u)^N));
  %% back-substituting for x
  Fu = subs(Iu, Ints, Old_Sums);
  Fp = subs(Fu, [u sin(u) cos(u)], [U Sin Cos]);
  Fp = Simplify(Fp, IAC{:});
  %% modifying the integral (case 1: [part 1])
  [expr cond] = branches(Fp);
  Children = sym(children(expr{1}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 1: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^k, prod([-1 Disc].^k));
  subvals = simplify(subvals, IAC{:});
  subvals = -subvals*(-1)^heaviside(k-1);
  %% modifying the integral (case 1: [part 3])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  %% modifying the integral (case 1: [part 4])
  G = gamma(-n-1/2)^S/gamma(-n-k-1/2);
  NK = npermk(-n-3/2, k);
  subvals = subs(subvals, G, NK);
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 1: [part 5])
  sublist = [(-1)^(-n-1/2); (-Disc)^(n+1/2); 1/(sqrt(a)*a^(n+2))];
  subvals = [1/sublist(1); prod([-1; Disc].^(n+1/2)); 1/a^(n+2+1/2)];
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 1: [part 6])
  expr{1} = sum(Children);
  cond{1} = cond{1} & (Disc ~= 0);
  %% modifying the integral (case 2: [part 1])
  Children = sym(children(expr{2}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 2: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^k, prod([-1 Disc].^k));
  subvals = -(-1)^(k+1)*(-1)^k*subvals;
  %% modifying the integral (case 2: [part 3])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 2: [part 4])
  expr{2} = sum(Children);
  cond{2} = cond{2} & (Disc ~= 0);
  %% modifying the integral (case 3: [part 1])
  sublist = findSymType(expr{3}, 'log').';
  subvals = [sublist(1); zeros(3,1)];
  expr{3} = subs(expr{3}, sublist, subvals);
  %% modifying the integral (case 3: [part 2])
  Atan = findSymType(expr{3}, 'atan');
  Atanh = subs(rewrite(Atan, 'atanh'), sqrt(-Disc), 1i*sqrt(Disc));
  sublist = [Atan; sqrt(-Disc)];
  subvals = sym.zeros(2, 1);
  subvals(1) = piecewise(Disc_is_pos, Atanh, ...
                         Disc_is_neg, Atan);
  subvals(2) = piecewise(Disc_is_pos, 1i*sqrt(Disc), ...
                         Disc_is_neg, sqrt(-Disc));
  expr{3} = subs(expr{3}, sublist, subvals);
  %% modifying the integral (case 4: [part 1])
  Children = sym(children(expr{4}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 4: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^k, prod([-1 Disc].^k));
  subvals = simplify(subvals, IAC{:});
  subvals = -subvals*(-1)^heaviside(k-1);
  %% modifying the integral (case 4: [part 4])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  %% modifying the integral (case 4: [part 5])
  G = gamma(-n-k)/gamma(-n)^S;
  NK = 1/npermk(-n-1, k);
  subvals = subs(subvals, G, NK);
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 4: [part 6])
  Atan = findSymType(Children(2), 'atan');
  Atanh = subs(rewrite(Atan, 'atanh'), sqrt(-Disc), 1i*sqrt(Disc));
  sublist = [Atan; (-Disc)^(n+1/2)];
  subvals = sym.zeros(2, 1);
  subvals(1) = piecewise(Disc_is_pos, Atanh, ...
                         Disc_is_neg, Atan);
  subvals(2) = piecewise(Disc_is_pos, prod([-1 Disc].^(n+1/2)), ...
                         Disc_is_neg, (-Disc)^(n+1/2));
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 4: [part 6])
  sublist = [-prod((-1).^([n+1/2 1-n]))*1i;
             (-1)^(1-n);
             gamma(-n)];
  subvals = [combine(sublist(1), IAC{:});
             (-1)^(n+1);
             factorial(-n-1)];
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 4: [part 7])
  expr{4} = sum(Children);
  %% modifying the integral (case 5: [part 1])
  Children = sym(children(expr{5}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 5: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^(k-1), prod([-1 Disc].^(k-1)));
  subvals = simplify(subvals, IAC{:});
  %% modifying the integral (case 5: [part 3])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  subvals = subs(subvals, k+S, k+1);
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 5: [part 4])
  expr{5} = sum(Children);
  cond{5} = cond{5} & (Disc ~= 0);
  %% modifying the integral (case 6: [part 1])
  Children = sym(children(expr{6}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 6: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^(k-1), prod([-1 Disc].^(k-1)));
  subvals = simplify(subvals, IAC{:});
  subvals = -subvals/(-1)^(2*k+1);
  %% modifying the integral (case 6: [part 3])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  subvals = -(-1)^S*subvals;
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 6: [part 4])
  num = 2*a*x+b;
  den = 2*sqrt(a)*sqrt(a*x^2+b*x+c);
  Atanh = -atanh(num/den);
  Asinh = -asinh(num/sqrt(-Disc));
  Atan = rewrite(Atanh, 'atan');
  Asin = subs(rewrite(Asinh, 'asin'), sqrt(-Disc), 1i*sqrt(Disc));
  sublist = [sum([1/2 -1].*findSymType(Children(2), 'log'));
             (-Disc)^(n+1/2)];
  subvals = sym.zeros(2,1);
  subvals(1) = piecewise(Disc_is_pos & a_is_pos, Atanh, ...
                         Disc_is_pos & a_is_neg, Asin, ...
                         Disc_is_neg & a_is_pos, Asinh, ...
                         Disc_is_neg & a_is_neg, Atan);
  subvals(2) = piecewise(Disc_is_pos, prod([-1 Disc].^(n+1/2)), ...
                         Disc_is_neg, (-Disc)^(n+1/2));
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 6: [part 5])
  sublist = (-1)^(-n-1/2);
  subvals = piecewise(Disc_is_neg & a_is_pos, (-1)^(n+1/2), ...
                      Disc_is_neg & a_is_neg, -(-1)^(n-1/2));
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 6: [part 6])
  sublist = gamma(n+3/2).^[S 1];
  subvals = factorial(n+1/2).^[S 1];
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 6: [part 7])
  expr{6} = sum(Children);
  %% modifying the integral (case 7: [part 1])
  Children = sym(children(expr{7}));
  Factors = sym(children(Children(2)));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Children(2) = sum(K*children(Children(2)/K));
  Children(2) = Simplify(Children(2), IAC{:});
  %% modifying the integral (case 7: [part 2])
  Factors = sym(children(sym(children(Children(2), 1))));
  Loc = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Loc));
  Old_Sum = findSymType(Children(2), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = simplify(subvals, IAC{:});
  subvals = subs(subvals, (-Disc)^(k-1), prod([-1 Disc].^(k-1)));
  subvals = simplify(subvals, IAC{:});
  subvals = -subvals/(-1)^(2*k+1);
  %% modifying the integral (case 7: [part 3])
  subvals = factor(subvals);
  loc = ~has(subvals, k);
  subvals(loc) = factor_power(subvals(loc), S);
  subvals = simplify(prod(subvals), IAC{:});
  %% modifying the integral (case 7: [part 4])
  G = gamma(n+1)^S/gamma(n-k+2);
  NK = npermk(n, k-1);
  subvals = subs(subvals, G, NK);
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(2) = subs(Children(2), Old_Sum, New_Sum);
  %% modifying the integral (case 7: [part 5])
  sublist = [(-Disc)^n;
             (2*a*beta-alpha*b)*(2*a*x+b);
             gamma(n+1)];
  subvals = [prod([-1 Disc].^n);
             (2*a*beta-alpha*b)*2*a*x;
             factorial(n)];
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 7: [part 6])
  sublist = children(Children(2), 2);
  subvals = prodfactor(sublist);
  subvals = combine(subvals, IAC{:});
  Children(2) = subs(Children(2), sublist, subvals);
  %% modifying the integral (case 7: [part 7])
  expr{7} = sum(Children);
  cond{7} = cond{7} & (Disc ~= 0);
  %% modifying the integral (converting back to piecewise)
  Fp = branches2piecewise(expr, cond);
  [Old_Sums New_Sums] = deal(findSymType(Fp, 'symsum').');
  for p = 1:length(Old_Sums)
    Children = children(Old_Sums(p));
    Children{4} = piecewise(2*a*beta-alpha*b == 0, 0, Children{4});
    New_Sums(p) = symsum(Children{:});
  end
  Fp = subs(Fp, Old_Sums, New_Sums);
  %% differentiating the integral
  func = @(arg) Simplify(arg, 5:6, IAC{:});
  [expr cond] = branches(Fp);
  expr = diff(expr, x);
  expr([2 7]) = arrayfun(func, expr([2 7]));
  Diff = branches2piecewise(expr, cond);
end
% =
function [Fp Diff] = Method_two(Fp, Diff, a, b, c, x, Disc)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integrals for
  %   method two
  % ---------------------------------

  %% remove the necessary branches
  Fp = remove_branches(Fp, [4 6 9:11]);
  [expr cond] = branches(Fp);
  sublist = [Disc > 0; b^2 ~= 4*a*c; a > 0];
  subvals = symtrue(size(sublist));
  cond = cellsubs(cond, sublist, subvals);
  cond = cond & (Disc ~= 0) & (a ~= 0);
  Fp = branches2piecewise(expr, cond);
  %% rewrite the atanh functions in terms of logs
  Arg = sym.zeros(2,1);
  Arg(1) = prod((2*a*x+b+[1; -1]*sqrt(Disc)).^[1; -1]);
  Arg(2) = 2*a*x+b+2*sqrt(a)*sqrt(a*x^2+b*x+c);
  Atanh = findSymType(Fp, 'atanh').';
  Log = [1/2; 1].*log(Arg);
  Fp = subs(Fp, Atanh, Log);
  %% modify the integral
  [expr cond] = branches(Fp);
  arg = factor(Arg(1)).^[1 -1];
  sublist = a*x^2+b*x+c;
  subvals = prod(arg);
  expr{3} = subs(expr{3}, sublist, subvals);
  expr{3} = collect(split_logs(expr{3}), log(arg));
  %% convert back to piecewise
  Fp = branches2piecewise(expr, cond);
  expr = sym(expr);
  expr([1 2 5 7]) = expression(Diff, [1 2 6 11]);
  expr([3 4 6]) = diff(expr([3 4 6]), x);
  Diff = branches2piecewise(expr, cond);
end
% =
function [F f tF dF sF cF] = output_fun(Fp, fp, dFp, args, Method) %#ok<INUSL>
  % -------------------------------
  % - helper function for computing
  %   the output arguments
  % -------------------------------
  
  %% initialize the output arguments
  [args{:} Method] = scalar_expand(args{:}, Method);
  emptys = cellfun(@isempty, args);
  if ~any(emptys)
    Zeros = num2cell(sym.zeros(size(args{1})));
  else
    Zeros = {sym(0)};
  end
  [F f tF dF sF cF] = deal(Zeros);
  %% compute the output arguments
  IAC = ",'IgnoreAnalyticConstraints',true";
  uniform = {'UniformOutput' false};
  for k = 1:numel(F)
    % ---------------------------------
    % symbolic function arguments
    Fp_args = num2cell(argnames(Fp.(Method(k))));
    [F_args argsk] = deal(cell2array(args, k));
    Vars2Exclude = sym(cellfun(@symvar, F_args(1:end-1), uniform{:}));
    Defaults = F_args{end};
    Args = {'Vars2Exclude' Vars2Exclude 'Defaults' Defaults};
    F_args{end} = randsym(Args{:});
    if ~isequal(F_args, Fp_args)
      rhs.Fp = Fp.(Method(k))(F_args{:});
      rhs.fp = fp.(Method(k))(F_args{:});
    else
      rhs.Fp = Fp.(Method(k));
      rhs.fp = fp.(Method(k));
    end
    % ---------------------------------
    % symbolic function calculation
    vars = argsk(1:end-1);
    vars = sym(cellfun(@symvar, vars, uniform{:}));
    vars = unique(vars, 'stable');
    vars_str = join(string(vars), ",");
    if ~isempty(vars)
      F{k}(vars) = rhs.Fp;
      f{k}(vars) = rhs.fp;
      at = "@("+vars_str+")";
      F_str = "F{%d}("+vars_str+")";
      f_str = "f{%d}("+vars_str+")";
      dFp_args = "cellsubs(F_args,vars,{"+vars_str+"})";
    else
      F{k} = rhs.Fp;
      f{k} = rhs.fp;
      at = "@()";
      F_str = "F{%d}";
      f_str = "f{%d}";
      dFp_args = "F_args";
    end
    dFp_str = "dFp.(Method(k))("+dFp_args+")";
    % ---------------------------------
    % test function handle strings
    tF_str = at+dFp_str+"-"+f_str;
    dF_str = at+dFp_str;
    sF_str = at+"simplify("+F_str+IAC+")";
    cF_str = at+"combine("+F_str+IAC+")";
    % ---------------------------------
    % test function handle calculations
    tF{k} = eval(sprintf(tF_str, k));
    dF{k} = eval(sprintf(dF_str));
    sF{k} = eval(sprintf(sF_str, k));
    cF{k} = eval(sprintf(cF_str, k));
    % ---------------------------------
  end
  %% convert the output arguments to a more convenient type
  if isscalar(F)
    [F f tF dF sF cF] = deal(F{1}, f{1}, tF{1}, dF{1}, sF{1}, cF{1});
  elseif all(cellfun(@isallsymnum, args(1:end-1)))
    F = reshape([F{:}], size(F));
    f = reshape([f{:}], size(f));
  end
end
% =
