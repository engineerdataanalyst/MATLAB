function [F f tF dF sF cF] = asechx_int(n, a, b, x)
  % - formula for this integral:
  % ----------------------------
  %  /
  %  | (a*x+b)^n*asech(a*x+b) dx
  %  /
  % ----------------------------
      
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    a sym = sym('a');
    b sym = sym('b');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {n a b x};
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
  [n a b x] = deal(sym('n'), sym('a'), sym('b'), sym('x'));
  fp(n, a, b, x) = (a*x+b)^n*asech(a*x+b);
  %% cases
  cases = [a == 0;
           n == -1 & a ~= 0;
           a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  [Fp Diff] = deal(sym.zeros(size(cases)));
  %% integral calculations
  % ------------------------
  % case 1: a == 0
  Fp(1) = b^n*asech(b)*x;
  Diff(1) = diff(Fp(1), x);
  % ------------------------
  % case 2: n == -1 & a ~= 0
  [Fp(2) Diff(2)] = n_neg_one(a, b, x);
  % ------------------------
  % case 3: a ~= 0
  [Fp(3) Diff(3)] = a_not_zero(n, a, b, x);
  % ------------------------
  %% converting to piecewise
  IAC = {'IgnoreAnalyticConstraints' true};
  Fp(n, a, b, x) = branches2piecewise(Fp, cases);
  Diff(n, a, b, x) = branches2piecewise(Diff, cases);
  dFp = @(dFp_args) Diff(dFp_args{:})-fp(dFp_args{:});
  dFp = @(dFp_args) simplify(dFp(dFp_args), IAC{:})+fp(dFp_args{:});
end
% =
function [Fp Diff] = n_neg_one(a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n == -1
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  IAC = {'IgnoreAnalyticConstraints' true};
  axb = a*x+b;
  %% integral calculation
  Term = sym.zeros(3,1);
  Term(1) = -asech(axb)*log(1+exp(-2*asech(axb)))/a;
  Term(2) = -asech(axb)^2/(2*a);
  Term(3) = polylog(2, -exp(-2*asech(axb)))/(2*a);
  Fp = sum(Term);
  %% differentiating the integral
  Diff = simplify(diff(Fp, x), IAC{:});
  Diff = simplify(simplifyFraction(Diff), IAC{:});
end
% =
function [Fp Diff] = a_not_zero(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  IAC = {'IgnoreAnalyticConstraints' true};
  [k u] = deal(sym('k'), sym('u')); 
  axb = a*x+b;
  S = heaviside(k-1);
  %% integration by parts
  sublist = sqrt(1/(axb)+[-1 1]).';
  subvals = [sqrt(1/axb^2-1) 1].';
  U = asech(axb);
  I = int(axb^n*U, x, 'Hold', true);
  I = integrateByParts(I, axb^n);
  I = subs(I, sublist, subvals);
  %% u-substitution
  Iu = changeIntegrationVariable(I, U, u);
  Iu = rewrite(Iu, 'sinh');
  Iu = combine(Iu, IAC{:});
  Iu = simplify(Iu, IAC{:});
  %% integral calculation
  func = @(~) sech_int(n+1, 1, 0, u, 'Method', 'two');
  Fu = mapSymType(Iu, 'int', func);
  Fu = order_branches(Fu, [3 1:2 4:6]);
  Fu = subs(Fu, n <= -1, n <= -3);
  %% back-substituting for x
  Sech = sech(U);
  Cosh = 1/Sech;
  Sinh = prod(sqrt(Cosh+[-1; 1]));
  Sinh = simplify(Sinh, IAC{:});
  Fp = subs(Fu, [sinh(u) cosh(u) sech(u)], [Sinh Cosh Sech]);
  Fp = subs(Fp, u, U);
  %% modifying the integral (case 1: [part 1])
  [expr cond] = branches(Fp);
  Children = sym(children(expr{1}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 1: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, 1/((1/axb)^(n+2*k)*axb), axb^(n+2*k-1));
  subvals = 1i*subvals*(-1)^(k+1/2)/(-1)^(k+1);
  %% modifying the integral (case 1: [part 3])
  subvals = factor(subvals);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 1: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 1: [part 5])
  sublist = (-1)^(n/2+1/2);
  subvals = -(-1)^(n/2-1/2);
  Children(1) = subs(Children(1), sublist, subvals);
  %% modifying the integral (case 1: [part 6])
  expr{1} = sum(Children);
  %% modifying the integral (case 2: [part 1])
  Children = sym(children(expr{2}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 2: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, 1/((1/axb)^(n+2*k)*axb), axb^(n+2*k-1));
  subvals = 1i*subvals*(-1)^(k+1/2)/(-1)^(k+1);
  %% modifying the integral (case 2: [part 3])
  subvals = factor(subvals);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 2: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 2: [part 5])
  sublist = (-1)^(n/2);
  subvals = 1i*(-1)^(n/2-1+1/2);
  Children(1) = subs(Children(1), sublist, subvals);
  %% modifying the integral (case 2: [part 6])
  expr{2} = sum(Children);
  %% modifying the integral (case 3: [part 1])
  Children = sym(children(expr{3}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 3: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, 1/((1/axb)^(n+2*k)*axb), axb^(n+2*k-1));
  %% modifying the integral (case 3: [part 3])
  subvals = factor(subvals);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 3: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 3: [part 5])
  expr{3} = sum(Children);
  %% modifying the integral (case 4: [part 1])
  Children = sym(children(expr{4}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 4: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, (1/axb)^(-n+2*k-2)/axb, axb^(n-2*k+1));
  subvals = 1i*subvals*(-1)^(S*(1+1/2));
  %% modifying the integral (case 4: [part 3])
  subvals = factor(subvals);
  subvals(1) = [];
  subvals(end) = -subvals(end);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 4: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 4: [part 5])
  expr{4} = sum(Children);
  %% modifying the integral (case 5: [part 1])
  Children = sym(children(expr{5}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 5: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, (1/axb)^(-n+2*k-2)/axb, axb^(n-2*k+1));
  subvals = -1i*subvals*(-1)^(k-1+1/2)/(-1)^(k+1);
  %% modifying the integral (case 5: [part 3])
  subvals = factor(subvals);
  subvals(1) = [];
  subvals(end) = -subvals(end);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 5: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 5: [part 5])
  sublist = (-1)^(n/2);
  subvals = -(-1)^(n/2+1);
  Children(1) = subs(Children(1), sublist, subvals);
  %% modifying the integral (case 5: [part 6])
  expr{5} = sum(Children);
  %% modifying the integral (case 6: [part 1])
  Children = sym(children(expr{6}));
  Factors = sym(children(Children(1)));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Children(1) = sum(K*children(Children(1)/K));
  %% modifying the integral (case 6: [part 2])
  Factors = sym(children(sym(children(Children(1), 1))));
  Ind = ~hasSymType(Factors, 'symsum');
  K = prod(Factors(Ind));
  Old_Sum = findSymType(Children(1), 'symsum');
  sublist = children(Old_Sum, 1);
  subvals = K*subs(sublist, S, 1);
  subvals = subs(subvals, (1/axb)^(-n+2*k-2)/axb, axb^(n-2*k+1));
  subvals = -1i*subvals*(-1)^(k-1+1/2)/(-1)^(k+1);
  %% modifying the integral (case 6: [part 3])
  subvals = factor(subvals);
  subvals(1) = [];
  subvals(end) = -subvals(end);
  ind = ~has(subvals, k);
  subvals(ind) = factor_power(subvals(ind), S);
  subvals = prod(simplify(subvals, IAC{:}));
  %% modifying the integral (case 6: [part 4])
  New_Sum = subs(Old_Sum, sublist, subvals)/K;
  Children(1) = subs(Children(1), Old_Sum, New_Sum);
  %% modifying the integral (case 6: [part 5])
  sublist = (-1)^(n/2+1/2);
  subvals = 1i*(-1)^(n/2+1/2-1+1/2);
  Children(1) = subs(Children(1), sublist, subvals);
  %% modifying the integral (case 6: [part 6])
  expr{6} = sum(Children);
  %% modifying the integral (converting back to piecewise)
  Fp = branches2piecewise(expr, cond);
  %% differentiating the integral
  Diff = Simplify(diff(Fp, x), IAC{:});
  Diff = Simplify(SimplifyFraction(Diff), IAC{:});
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
