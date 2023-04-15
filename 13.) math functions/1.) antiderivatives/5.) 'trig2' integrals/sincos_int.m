function [F f tF dF sF cF] = sincos_int(n, p, a, b, x)
  % - formula for this integral:
  % -------------------------------
  %  /
  %  | sin(a*x+b)^n*cos(a*x+b)^p dx
  %  /
  % -------------------------------
    
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    p sym = sym('p');
    a sym = sym('a');
    b sym = sym('b');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {n p a b x};
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
  % -------------------------------
  % - helper function for computing
  %   the persistent integrals
  % -------------------------------

  %% integrand
  [n p a b x] = deal(sym('n'), sym('p'), sym('a'), sym('b'), sym('x'));
  fp.non_handle(n, p, a, b, x) = sin(a*x+b)^n*cos(a*x+b)^p;
  %% cases
  np_is_pos_int = isint(-(n+p)/2, 'Type', 'positive');
  n_is_nonneg_even = iseven(n, 'Type', 'positive or zero');
  n_is_pos_even = iseven(n, 'Type', 'positive');
  n_is_neg_even = iseven(n, 'Type', 'negative');
  n_is_pos_odd = isodd(n, 'Type', 'positive');
  n_is_neg_odd = isodd(n, 'Type', 'negative');
  p_is_nonneg_even = iseven(p, 'Type', 'positive or zero');
  p_is_pos_even = iseven(p, 'Type', 'positive');
  p_is_neg_even = iseven(p, 'Type', 'negative');
  p_is_pos_odd = isodd(p, 'Type', 'positive');
  p_is_neg_odd = isodd(p, 'Type', 'negative');
  cases = [a == 0;
           np_is_pos_int & a ~= 0;
           n_is_pos_odd & a ~= 0;
           p_is_pos_odd & a ~= 0;
           n_is_nonneg_even & p_is_neg_odd & a ~= 0;
           n_is_nonneg_even & p_is_nonneg_even & a ~= 0;
           n_is_neg_odd & p_is_nonneg_even & a ~= 0;
           n_is_neg_even & p_is_neg_odd & a ~= 0;
           n_is_neg_even & p_is_pos_even & -n <= p & a ~= 0;
           n_is_neg_odd & p_is_neg_even & a ~= 0;
           n_is_pos_even & p_is_neg_even & n >= -p & a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  % ---------------------------------------------------------
  % case 1: a == 0
  Fp(1) = sin(b)^n*cos(b)^p*x;
  % ---------------------------------------------------------
  % case 2: np_is_nonneg_int & a ~= 0
  Fp(2) = np_pos_int(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 3: n_is_pos_odd & a ~= 0
  Fp(3) = n_pos_odd(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 4: p_is_pos_odd & a ~= 0
  Fp(4) = p_pos_odd(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 5: n_is_nonneg_even & p_is_neg_odd & a ~= 0
  Fp(5) = n_nonneg_even_p_neg_odd(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 6: n_is_nonneg_even & p_is_nonneg_even & a ~= 0
  Fp(6) = n_nonneg_even_p_nonneg_even(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 7: n_is_neg_odd & p_is_nonneg_even & a ~= 0
  Fp(7) = n_neg_odd_p_nonneg_even(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 8: n_is_neg_even & p_is_neg_odd & a ~= 0
  Fp(8) = n_neg_even_p_neg_odd(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 9: n_is_neg_even & p_is_pos_even & -n <= p & a ~= 0
  Fp(9) = n_neg_even_p_pos_even(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 10: n_is_neg_odd & p_is_neg_even & a ~= 0
  Fp(10) = n_neg_odd_p_neg_even(n, p, a, b, x);
  % ---------------------------------------------------------
  % case 11: n_is_pos_even & p_is_neg_even & n >= -p & a ~= 0
  Fp(11) = n_pos_even_p_neg_even(n, p, a, b, x);
  % ---------------------------------------------------------
  %% converting to piecewise
  IAC = {'IgnoreAnalyticConstraints' true};
  Fp(n, p, a, b, x) = branches2piecewise(Fp, cases);
  fp.handle = @(dFp_args) handle_fun(Fp, fp, dFp_args, "fp");
  dFp = @(dFp_args) handle_fun(Fp, fp, dFp_args, "dFp");
  dFp = @(dFp_args) dFp(dFp_args)-fp.handle(dFp_args);
  dFp = @(dFp_args) simplify(dFp(dFp_args), IAC{:})+ ...
                             fp.non_handle(dFp_args{:});
end
% =
function h = handle_fun(Fp, fp, dFp_args, h_type)
  % ---------------------------------
  % - helper function for computing
  %   the persistent function handles
  % ---------------------------------
  IAC = {'IgnoreAnalyticConstraints' true};
  switch h_type
    case "fp"
      h = simplify(fp.non_handle, IAC{:});
      h = h(dFp_args{:});
    case "dFp"
      func = cell(2,1);
      func{1} = @(arg) Simplify(arg, IAC{:});
      func{2} = @(arg, var) diff(arg, var);
      h = rewrite(Fp(dFp_args{:}), 'sincos');
      h = arrayfun(func{1}, h);
      h = arrayfun(func{2}, h, dFp_args{end});
      h = simplifyFraction(h);
      h = simplify(h, IAC{:});
  end
end
% =
function Fp = np_pos_int(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 2:
  % - -(n+p)/2 is a positive integer
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = -n/2+[-p/2-1; -1/2; -p/2];
  S = [sign(abs(n+2*k-1)); integer(-N(2)); heaviside(k-1)];
  %% constant calculations
  K.tan = nchoosek(N(1), k-1)*S(1)/(a^S(3)*(n+2*k-S(1)));
  K.log_tan = nchoosek(N(1), N(2))*S(2)/a;
  %% term calculations
  Term.tan = K.tan*tan(axb)^(n+2*k-1);
  Term.log_tan = K.log_tan*log(tan(axb));
  %% integral calculation
  Fp = symsum(Term.tan, k, 1, N(3))+Term.log_tan;
end
% =
function Fp = n_pos_odd(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 3:
  % - n is a positive odd integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [n/2-1/2; -p/2-1/2; n/2+1/2];
  S = [sign(abs(p+2*k-1)); integer(-N(2)); heaviside(k-1)];
  %% constant calculations
  K.cos = (-1)^k*nchoosek(N(1), k-1)*S(1)/(a^S(3)*(p+2*k-S(1)));
  K.log_cos = (-1)^(-N(2)-1)*nchoosek(N(1), N(2))*S(2)/a;
  %% term calculations
  Term.cos = K.cos*cos(axb)^(p+2*k-1);
  Term.log_cos = K.log_cos*log(cos(axb));
  %% integral calculation
  Fp = symsum(Term.cos, k, 1, N(3))+Term.log_cos;
end
% =
function Fp = p_pos_odd(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 4:
  % - p is a positive odd integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [p/2-1/2; -n/2-1/2; p/2+1/2];
  S = [sign(abs(n+2*k-1)); integer(-N(2)); heaviside(k-1)];
  %% constant calculations
  K.sin = (-1)^(k+1)*nchoosek(N(1), k-1)*S(1)/(a^S(3)*(n+2*k-S(1)));
  K.log_sin = (-1)^-N(2)*nchoosek(N(1), N(2))*S(2)/a;
  %% term calculations
  Term.sin = K.sin*sin(axb)^(n+2*k-1);
  Term.log_sin = K.log_sin*log(sin(axb));
  %% integral calculation
  Fp = symsum(Term.sin, k, 1, N(3))+Term.log_sin;
end
% =
function Fp = n_nonneg_even_p_neg_odd(n, p, a, b, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 5:
  % - n is a non-negative even integer
  % - p is a negative odd integer
  % - a ~= 0
  % ----------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [n/2; -n/2+[1/2; -p/2]; -p/2];
  Arg = [k-1; k+N(2:3); N(2:3); N(4)];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:5 5 4 6])).^[1; -1; -S; S; 1; -ones(2,1)];
  %% constant calculations
  K.sincos = prod(G(1:4))/((-a)^S*(n-2*k+1));
  K.cos = prod(G(5:7))*sqrt(sympi);
  %% constant modifications
  K.cos = factor_power(K.cos, S);
  K.cos = simplify(K.cos, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^(n-2*k+1)*cos(axb)^((p+1)*S);
  Term.cos = expression(cos_int(p, a, b, x, Method='two'), 4);
  %% term modifications
  sublist = children(findSymType(Term.cos, 'symsum'), 1);
  subvals = K.cos*sublist;
  Children = sym(children(Term.cos));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.cos*Children(2), k, 1);
  Term.cos = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.cos;
end
% =
function Fp = n_nonneg_even_p_nonneg_even(n, p, a, b, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 6:
  % - n is a non-negative even integer
  % - p is a non-negative even integer
  % - a ~= 0
  % ----------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [n/2+[0; p/2]; -n/2+1/2; n/2];
  Arg = [k-1; [k; 0]+N(3)];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:3 3])).^[1; -S; -1];
  %% constant calculations
  K.sincos = (-1)^(k+1)*prod(G(1:2))/(a^S*(n-2*k+1)*npermk(N(2), k));
  K.cos = (-1)^N(4)*G(3)*sqrt(sympi)/npermk(N(2), N(1));
  %% constant modifications
  K.cos = factor_power(K.cos, S);
  K.cos = simplify(K.cos, 'IgnoreAnalyticConstraints', true);
  K.cos = subs(K.cos, N(4)*S, N(4));
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^(n-2*k+1)*cos(axb)^((p+1)*S);
  Term.cos = expression(cos_int(p, a, b, x, Method='two'), 5);
  %% term modifications
  Neg1 = [prod((-1).^([k; N(4)])); (-1)^(k+N(4))];
  sublist = children(findSymType(Term.cos, 'symsum'), 1);
  subvals = subs(K.cos*sublist, Neg1(1), Neg1(2));
  Children = sym(children(Term.cos));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.cos*Children(2), k, 1);
  Children(2) = combine(Children(2), 'IgnoreAnalyticConstraints', true);
  Term.cos = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.cos;
end
% =
function Fp = n_neg_odd_p_nonneg_even(n, p, a, b, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 7:
  % - n is a negative odd integer
  % - p is a non-negative even integer
  % - a ~= 0
  % ----------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  P = [p/2; -p/2+[1/2; -n/2]; -n/2];
  Arg = [k-1; P(2:3); k+P(2:3); P(4)];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:5 3 2 6])).^[-S; S; 1; -1; 1; -ones(2,1)];
  %% constant calculations
  K.sincos = prod(G(1:4))/(a^S*(p-2*k+1));
  K.sin = prod(G(5:7))*sqrt(sympi);
  %% constant modifications
  K.sin = factor_power(K.sin, S);
  K.sin = simplify(K.sin, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^((n+1)*S)*cos(axb)^(p-2*k+1);
  Term.sin = expression(sin_int(n, a, b, x, Method='two'), 4);
  %% term modifications
  sublist = children(findSymType(Term.sin, 'symsum'), 1);
  subvals = K.sin*sublist;
  Children = sym(children(Term.sin));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.sin*Children(2), k, 1);
  Children(2) = combine(Children(2), 'IgnoreAnalyticConstraints', true);
  Term.sin = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, P(1))+Term.sin;
end
% =
function Fp = n_neg_even_p_neg_odd(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 8:
  % - n is a negative even integer
  % - p is a negative odd integer
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [-n/2; n/2+[1/2; p/2+1]; p/2+1];
  Arg = [k-1; k+N(2:3); N(2:3); N(4)];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:5 4 6 5])).^[-1; 1; S; -S; ones(2,1); -1];
  %% constant calculations
  K.sincos = prod(G(1:4))/(a^S*(n+p+2*k));
  K.cos = prod(G(5:7))/sqrt(sympi);
  %% constant modifications
  K.cos = factor_power(K.cos, S);
  K.cos = simplify(K.cos, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^(n+2*k-1)*cos(axb)^((p+1)*S);
  Term.cos = expression(cos_int(p, a, b, x, Method='two'), 4);
  %% term modifications
  sublist = children(findSymType(Term.cos, 'symsum'), 1);
  subvals = K.cos*sublist;
  Children = sym(children(Term.cos));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.cos*Children(2), k, 1);
  Term.cos = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.cos;
end
% =
function Fp = n_neg_even_p_pos_even(n, p, a, b, x) 
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 9:
  % - n is a negative even integer
  % - p is a positive even integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [-n/2; n/2+1/2; p/2+[n/2+k; 0]];
  Arg = [k-1; N(2)+[k; 0]];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:3 3])).^[-1; S; 1];
  %% constant calculations
  K.sincos = prod(G(1:2))*npermk(N(3), k)/(a^S*(n+p+2*k));
  K.cos = G(3)*npermk(N(4), N(1))/sqrt(sympi);
  %% constant modifications
  K.cos = factor_power(K.cos, S);
  K.cos = simplify(K.cos, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^(n+2*k-1)*cos(axb)^((p+1)*S);
  Term.cos = expression(cos_int(p, a, b, x, Method='two'), 5);
  %% term modifications
  sublist = children(findSymType(Term.cos, 'symsum'), 1);
  subvals = K.cos*sublist;
  Children = sym(children(Term.cos));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.cos*Children(2), k, 1);
  Children(2) = combine(Children(2), 'IgnoreAnalyticConstraints', true);
  Term.cos = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.cos;
end
% =
function Fp = n_neg_odd_p_neg_even(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 10:
  % - n is a negative odd integer
  % - p is a negative even integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [-p/2; p/2+1/2; n/2+[p/2+1; 1]];
  Arg = [k-1; N(2)+[k; 0]; N(3)+[k; 0]; N(4)];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:5 6 3 5])).^[-1; S; 1; -S; ones(2,1); -1];
  %% constant calculations
  K.sincos = prod(G(1:4))/((-a)^S*(n+p+2*k));
  K.sin = prod(G(5:7))/sqrt(sympi);
  %% constant modifications
  K.sin = factor_power(K.sin, S);
  K.sin = simplify(K.sin, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^((n+1)*S)*cos(axb)^(p+2*k-1);
  Term.sin = expression(sin_int(n, a, b, x, Method='two'), 4);
  %% term modifications
  sublist = children(findSymType(Term.sin, 'symsum'), 1);
  subvals = K.sin*sublist;
  Children = sym(children(Term.sin));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.sin*Children(2), k, 1);
  Term.sin = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.sin;
end
% =
function Fp = n_pos_even_p_neg_even(n, p, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 11:
  % - n is a positive even integer
  % - p is a negative even integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = [-p/2; p/2+1/2; n/2+[p/2; 0]];
  Arg = [k-1; N(2)+[k; 0]];
  S = heaviside(Arg(1));
  G = gamma(Arg([2:3 3])).^[-1; S; 1];
  %% constant calculations
  K.sincos = prod(G(1:2))*npermk(N(3)+k, k)/((-a)^S*(n+p+2*k));
  K.sin = G(3)*npermk(N(4), N(1))/sqrt(sympi);
  %% constant modifications
  K.sin = factor_power(K.sin, S);
  K.sin = simplify(K.sin, 'IgnoreAnalyticConstraints', true);
  %% term calculations
  Term.sincos = K.sincos*sin(axb)^((n+1)*S)*cos(axb)^(p+2*k-1);
  Term.sin = expression(sin_int(n, a, b, x, Method='two'), 5);
  %% term modifications
  sublist = children(findSymType(Term.sin, 'symsum'), 1);
  subvals = K.sin*sublist;
  Children = sym(children(Term.sin));
  Children(1) = subs(Children(1), sublist, subvals);
  Children(2) = subs(K.sin*Children(2), k, 1);
  Term.sin = sum(Children);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N(1))+Term.sin;
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
  for k = 1:numel(F)
    % ---------------------------------
    % symbolic function arguments
    Fp_args = num2cell(argnames(Fp));
    fp_non_handle = @(args) fp.non_handle(args{:}); %#ok<NASGU>
    [F_args argsk] = deal(cell2array(args, k));
    Vars2Exclude = sym(cellfun(@symvar, F_args(1:end-1), uniform{:}));
    Defaults = F_args{end};
    Args = {'Vars2Exclude' Vars2Exclude 'Defaults' Defaults};
    F_args{end} = randsym(Args{:});
    if ~isequal(F_args, Fp_args)
      rhs.Fp = Fp(F_args{:});
      rhs.fp.non_handle = fp.non_handle(F_args{:});
    else
      rhs.Fp = Fp;
      rhs.fp.non_handle = fp.non_handle;
    end
    % ---------------------------------
    % symbolic function calculation
    vars = argsk(1:end-1);
    vars = sym(cellfun(@symvar, vars, uniform{:}));
    vars = unique(vars, 'stable');
    vars_str = join(string(vars), ",");
    if ~isempty(vars)
      F{k}(vars) = rhs.Fp;
      f{k}(vars) = rhs.fp.non_handle;
      at = "@("+vars_str+")";
      F_str = "F{%d}("+vars_str+")";
      dFp_args = "cellsubs(F_args,vars,{"+vars_str+"})";
    else
      F{k} = rhs.Fp;
      f{k} = rhs.fp.non_handle;
      at = "@()";
      F_str = "F{%d}";
      dFp_args = "F_args";
    end
    dFp_str = "dFp("+dFp_args+")";
    fp_non_handle_str = "fp_non_handle("+dFp_args+")";
    % ---------------------------------
    % test function handle strings
    tF_str = at+dFp_str+"-"+fp_non_handle_str;
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
