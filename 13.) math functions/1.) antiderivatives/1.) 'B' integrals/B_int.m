function [F f tF dF sF cF] = B_int(n, p, a, b, B, x)
  % - formula for this integral:
  % ---------------------
  %  /
  %  | x^n*B^(a*x^p+b) dx
  %  /
  % ---------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    p sym = sym('p');
    a sym = sym('a');
    b sym = sym('b');
    B sym = sym('B');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {n p a b B x};
  if ~compatible_dims(args{:})
    error('input arguments must have compatible dimensions');
  end
  % check the integration variable
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  end
  %% compute the integral
  persistent Fp fp dFp;
  if isempty(Fp)
    [Fp fp dFp] = persistent_fun;
  end
  [F f tF dF sF cF] = output_fun(Fp, fp, dFp, args);
end
% =
function [Fp fp dFp] = persistent_fun
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integrals
  % ---------------------------------

  %% integrand
  [n p a b B x] = deal(sym('n'), sym('p'), sym('a'), sym('b'), ...
                       sym('B'), sym('x'));
  fp(n, p, a, b, B, x) = x^n*B^(a*x^p+b);
  %% cases
  cases = [p == 0 | a == 0 | B == 0 | B == 1;
           p ~= 0 & a ~= 0 & B ~= 0 & B ~= 1];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  % -----------------------------------------
  % case 1: p == 0 | a == 0 | B == 0 | B == 1
  Fp(1) = B^(a+b)*piecewise(n == -1, log(x), ...
                            n ~= -1, x^(n+1)/(n+1));
  % -----------------------------------------
  % case 2: p ~= 0 & a ~= 0 & B ~= 0 & B ~= 1
  Fp(2) = pabB_not_zero_int(n, p, a, b, B, x);
  % -----------------------------------------
  %% converting to piecewise
  Fp(n, p, a, b, B, x) = branches2piecewise(Fp, cases);
  dFp = @(dFp_args) handle_fun(Fp, fp, dFp_args);
end
% =
function h = handle_fun(Fp, fp, dFp_args)
  % --------------------------------
  % - helper function for computing
  %   the persistent function handle
  % --------------------------------
  emptys = cellfun(@isempty, dFp_args);
  if ~any(emptys)
    IAC = {'IgnoreAnalyticConstraints' true};
    func = @(arg, X) diff(arg, X);
    Fp = Fp(dFp_args{:});
    fp = fp(dFp_args{:});
    h = arrayfun(func, Fp, dFp_args{end})-fp;
    h = simplify(h, IAC{:})+fp;
  else
    h = fp(dFp_args{:});
  end
end
% =
function Fp = pabB_not_zero_int(n, p, a, b, B, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - p ~= 0
  % - a ~= 0
  % - b ~= 0
  % - B ~= 0
  % ---------------------------------
  
  %% integration variables
  [k u] = deal(sym('k'), sym('u'));
  axp = a*x^p;
  n1p = (n+1)/p;
  axp_log = a*x^p*log(B);
  sqrt_axp_log = sqrt(a)*x^(p/2)*sqrt(log(B));
  a_log = a*log(B);
  Arg = [[1; -1]*SignIm(a_log); k-1];
  S = heaviside(Arg);
  KBab = B^b/(a^n1p*p*log(B));
  Kab = B^b/KBab;
  %% u-substitution (part 1)
  assume([x a p u B], 'positive');
  U = B^(axp);
  I = int(x^n*B^(axp+b), x, 'Hold', true);
  Iu = changeIntegrationVariable(I, U, u);
  clearassum;
  %% u-substitution (part 2)
  K = log(B)^n1p/(log(B)^(n1p-1)*log(B));
  Iu = K*simplify(Iu, 'IgnoreAnalyticConstraints', true);
  sublist = [(n-p+1)/p; log(u)^(n1p-1)];
  subvals = [n1p-1; sublist(2)/log(B)^(n1p-1)];
  Iu = subs(Iu, sublist(1), subvals(1));
  Iu = subs(Iu, sublist(2), subvals(2))/log(B)^(1-n1p);
  %% integral calculation
  func = @(~) logB_int(0, n1p-1, 1, 0, B, u)/KBab;
  Iu = mapSymType(Iu, 'int', func);
  %% back substituting for x
  Fp = subs(Iu, u, U);
  Fp = split_logs(Fp);
  sublist = erfi(sqrt(axp_log));
  subvals = sym.zeros(2,1);
  subvals(1) = erfi(sqrt_axp_log)*S(1);
  subvals(2) = -1i*erf(1i*sqrt_axp_log)*S(2);
  subvals = sum(subvals);
  Fp = subs(Fp, sublist, subvals);
  %% modifying the integral (K factor: negative integer case [part 1])
  [expr cond] = branches(Fp);
  expr{1} = sum(KBab*children(expr{1}));
  Term = children(expr{1}, 1);
  sublist = [Term;
             children(findSymType(Term, 'symsum'), 1);
             B^axp*B^b];
  subvals = [Term*Kab;
             sublist(2)/Kab^S(3);
             B^(axp+b)];
  expr{1} = subs(expr{1}, sublist(1), subvals(1));
  expr{1} = subs(expr{1}, sublist(2:3), subvals(2:3));
  %% modifying the integral (K factor: negative integer case [part 2])
  sublist = [(log(B)^(n1p-1))^S(3);
             axp_log^(k+n1p-1);
             Kab^S(3)];
  subvals = sublist;
  subvals(1) = simplify(subvals(1), 'IgnoreAnalyticConstraints', true);
  for t = 2:3
    [Base Exponent] = power_parts(subvals(t));
    subvals(t) = factor_power(Base, Exponent);
    subvals(t) = simplify(subvals(t), 'IgnoreAnalyticConstraints', true);
  end
  old = children(subvals(2), 3);
  new = simplify(old, 'IgnoreAnalyticConstraints', true);
  subvals(2) = subs(subvals(2), old, new);
  expr{1} = subs(expr{1}, sublist, subvals);
  %% modifying the integral (K factor: negative integer case [part 3])
  Children = children(expr{1}, 1);
  Combined = combine(Children, 'IgnoreAnalyticConstraints', true);
  Factors = sym(children(children(findSymType(Combined, 'symsum'), 1)));
  Logs = hasSymType(Factors, 'log');
  sublist = [Children;
             prod(Factors(Logs));
             k+n1p-S(3)*n1p-1;
             (n-p-S(3)-n*S(3)+k*p+1)/p;
             n-p+k*p+1;
             prod(log(B).^(1-[n1p; 2]))];
  subvals = [Combined;
             simplify(sublist(2), 'IgnoreAnalyticConstraints', true);
             k-1;
             k-1;
             n+p*(k-1)+1;
             simplify(sublist(6), 'IgnoreAnalyticConstraints', true)];
  subvals(2) = subs(subvals(2), (-1)^S(3)/p^S(3), 1/(-p)^S(3));
  expr{1} = subs(expr{1}, sublist(1), subvals(1));
  expr{1} = subs(expr{1}, sublist(2), subvals(2));
  expr{1} = subs(expr{1}, sublist(2:3), subvals(2:3));
  expr{1} = subs(expr{1}, sublist(4:6), subvals(4:6));
  %% modifying the integral (K factor: negative half value case [part 1])
  expr{2} = sum(KBab*children(expr{2}));
  Term = children(expr{2}, 1);
  sublist = [Term;
             children(findSymType(Term, 'symsum'), 1);
             B^axp*B^p;
             (-1)^(n1p-3/2)];
  subvals = [Term*Kab;
             sublist(2)/Kab^S(3);
             B^(axp+b);
             -(-1)^(n1p-1/2)];
  expr{2} = subs(expr{2}, sublist(1), subvals(1));
  expr{2} = subs(expr{2}, sublist(2:4), subvals(2:4));
  %% modifying the integral (K factor: negative half value case [part 2])
  sublist = [(log(B)^(n1p-1))^S(3);
             axp_log^(k+n1p-1);
             Kab^S(3)];
  subvals = sublist;
  subvals(1) = simplify(subvals(1), 'IgnoreAnalyticConstraints', true);
  for t = 2:3
    [Base Exponent] = power_parts(subvals(t));
    subvals(t) = factor_power(Base, Exponent);
    subvals(t) = simplify(subvals(t), 'IgnoreAnalyticConstraints', true);
  end
  old = children(subvals(2), 3);
  new = simplify(old, 'IgnoreAnalyticConstraints', true);
  subvals(2) = subs(subvals(2), old, new);
  expr{2} = subs(expr{2}, sublist, subvals);
  %% modifying the integral (K factor: negative half value case [part 3])
  sublist = [children(expr{2}, 1);
             k+n1p-S(3)*n1p-1;
             (n-p-S(3)*p+k*p+1)/p-S(3)*(n1p-1)
             n-p+k*p+1;
             (gamma(n1p)/p)^S(3);
             prod(log(B).^(1-[n1p; 2]))];
  subvals = [combine(sublist(1), 'IgnoreAnalyticConstraints', true);
             k-1;
             k-1;
             n+p*(k-1)+1;
             gamma(n1p)^S(3)/p^S(3);
             simplify(sublist(6), 'IgnoreAnalyticConstraints', true)];
  expr{2} = subs(expr{2}, sublist(1), subvals(1));
  expr{2} = subs(expr{2}, sublist(2:3), subvals(2:3));
  expr{2} = subs(expr{2}, sublist(4:6), subvals(4:6));
  %% modifying the integral (K factor: negative half value case [part 4])
  sublist = children(expr{2}, 2);
  subvals = sym(children(sublist));
  K = prod(subvals(1:end-1));
  subvals = prod(subvals)/K;
  subvals = K*children(subvals);
  subvals(2) = subs(subvals(2), (-1)^(n1p-1/2), -(-1)^(n1p+1/2));
  subvals = sum(subvals);
  expr{2} = subs(expr{2}, sublist, subvals);
  %% modifying the integral (K factor: non-negative integer case [part 1])
  expr{3} = KBab*expr{3};
  sublist = [expr{3};
             children(findSymType(expr{3}, 'symsum'), 1);
             B^axp*B^b];
  subvals = [expr{3}*Kab;
             sublist(2)/Kab^S(3);
             B^(axp+b)];
  expr{3} = subs(expr{3}, sublist(1), subvals(1));
  expr{3} = subs(expr{3}, sublist(2:3), subvals(2:3));
  %% modifying the integral (K factor: non-negative integer case [part 2])
  sublist = [(log(B)^(n1p-1))^S(3);
             axp_log^(n1p-k);
             Kab^S(3)];
  subvals = sublist;
  subvals(1) = simplify(subvals(1), 'IgnoreAnalyticConstraints', true);
  for t = 2:3
    [Base Exponent] = power_parts(subvals(t));
    subvals(t) = factor_power(Base, Exponent);
    subvals(t) = simplify(subvals(t), 'IgnoreAnalyticConstraints', true);
  end
  old = children(subvals(2), 3);
  new = simplify(old, 'IgnoreAnalyticConstraints', true);
  subvals(2) = subs(subvals(2), old, new);
  expr{3} = subs(expr{3}, sublist, subvals);
  %% modifying the integral (K factor: non-negative integer case [part 3])
  sublist = [expr{3};
             n1p-k-S(3)*n1p;
             (n-S(3)*p-k*p+1)/p-S(3)*(n1p-1)];
  subvals = [combine(sublist(1), 'IgnoreAnalyticConstraints', true);
             -k;
             -k];
  expr{3} = subs(expr{3}, sublist(1), subvals(1));
  expr{3} = subs(expr{3}, sublist(2:3), subvals(2:3));
  %% modifying the integral (K factor: positive half value case [part 1])
  expr{4} = sum(KBab*children(expr{4}));
  Term = children(expr{4}, 1);
  sublist = [Term;
             children(findSymType(Term, 'symsum'), 1);
             B^axp*B^b];
  subvals = [Term*Kab;
             sublist(2)/Kab^S(3);
             B^(axp+b);];
  expr{4} = subs(expr{4}, sublist(1), subvals(1));
  expr{4} = subs(expr{4}, sublist(2:3), subvals(2:3));
  %% modifying the integral (K factor: positive half value case [part 2])
  sublist = [(log(B)^(n1p-1))^S(3);
             axp_log^(k+n1p-1);
             Kab^S(3)];
  subvals = sublist;
  subvals(1) = simplify(subvals(1), 'IgnoreAnalyticConstraints', true);
  for t = 2:3
    [Base Exponent] = power_parts(subvals(t));
    subvals(t) = factor_power(Base, Exponent);
    subvals(t) = simplify(subvals(t), 'IgnoreAnalyticConstraints', true);
  end
  old = children(subvals(2), 3);
  new = simplify(old, 'IgnoreAnalyticConstraints', true);
  subvals(2) = subs(subvals(2), old, new);
  expr{4} = subs(expr{4}, sublist, subvals);
  %% modifying the integral (K factor: positive half value case [part 3])
  sublist = [children(expr{4}, 1);
             (S(3)-n+S(3)*n+k*p-1)/p;
             (2*n-p+2)/(2*p);
             -(n-p*[k; 1]+1)/p;
             prod(log(B).^(1-[n1p; 2]))];
  subvals = [combine(sublist(1), 'IgnoreAnalyticConstraints', true);
             k;
             n1p-1/2;
             [k; 1]-n1p;
             simplify(sublist(6), 'IgnoreAnalyticConstraints', true)];
  subvals(1) = simplify(subvals(1), 'IgnoreAnalyticConstraints', true);
  expr{4} = subs(expr{4}, sublist(1), subvals(1));
  expr{4} = subs(expr{4}, sublist(2), subvals(2));
  expr{4} = subs(expr{4}, sublist(3:6), subvals(3:6));
  %% modifying the integral (K factor: positive half value case [part 3])
  sublist = children(expr{4}, 2);
  subvals = sym(children(sublist));
  K = prod(subvals(1:end-1));
  subvals = prod(subvals)/K;
  subvals = K*children(subvals);
  subvals = sum(subvals);
  expr{4} = subs(expr{4}, sublist, subvals);
  %% converting back to piecewise
  pw = [cond expr].';
  Fp = piecewise(pw{:});
end
% =
function [F f tF dF sF cF] = output_fun(Fp, fp, dFp, args) %#ok<INUSL> 
  % -------------------------------
  % - helper function for computing
  %   the output arguments
  % -------------------------------
  
  %% initialize the output arguments
  [args{:}] = scalar_expand(args{:});
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
  Fp_args = num2cell(argnames(Fp));
  for k = 1:numel(F)
    % ---------------------------------
    % symbolic function arguments
    [F_args argsk] = deal(cell2array(args, k));
    Vars2Exclude = sym(cellfun(@symvar, F_args(1:end-1), uniform{:}));
    Defaults = F_args{end};
    Args = {'Vars2Exclude' Vars2Exclude 'Defaults' Defaults};
    F_args{end} = randsym(Args{:});
    if ~isequal(F_args, Fp_args)
      rhs.Fp = Fp(F_args{:});
      rhs.fp = fp(F_args{:});
    else
      rhs.Fp = Fp;
      rhs.fp = fp;
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
    dFp_str = "dFp("+dFp_args+")";
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
