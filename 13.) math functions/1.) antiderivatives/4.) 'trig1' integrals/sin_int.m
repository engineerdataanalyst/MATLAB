function [F f tF dF sF cF] = sin_int(n, a, b, x, options)
  % - formula for this integral:
  % ------------------
  %  /
  %  | sin(a*x+b)^n dx
  %  /
  % ------------------
  % - using these methods:
  %   1.) trig identities
  %   2.) power-reducing formulas
  
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    a sym = sym('a');
    b sym = sym('b');
    x sym = sym('x');
    options.Method ...
    {mustBeText, mustBeMemberi(options.Method, ["one" "two"])};
  end
  % check the argument dimensions
  args = {n a b x};
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
      [F.(k) f.(k) tF.(k) dF.(k) sF.(k) cF.(k)] = sin_int(Args{:});
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
  [n a b x] = deal(sym('n'), sym('a'), sym('b'), sym('x'));
  fp(n, a, b, x) = sin(a*x+b)^n;
  fp = default_struct('one', 'two', 'Default', fp);
  %% cases
  n_is_neg_even = iseven(n, 'Type', 'negative');
  n_is_nonpos_half = isint(n+1/2, 'Type', 'negative or zero');
  n_is_neg_odd = isodd(n, 'Type', 'negative');
  n_is_nonneg_even = iseven(n, 'Type', 'positive or zero');
  n_is_nonneg_half = isint(n-1/2, 'Type', 'positive or zero');
  n_is_pos_odd = isodd(n, 'Type', 'positive');
  cases = [a == 0;
           n_is_neg_even & a ~= 0;
           n_is_nonpos_half & a ~= 0;
           n_is_neg_odd & a ~= 0;
           n_is_nonneg_even & a ~= 0;
           n_is_nonneg_half & a ~= 0;
           n_is_pos_odd & a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  [Fp.one Fp.two] = deal(sym.zeros(size(cases)));
  %% integral calculations
  % ---------------------------------
  % case 1: a == 0
  Fp.one(1) = sin(b)^n*x;
  Fp.two(1) = Fp.one(1);
  % ---------------------------------
  % case 2: n_is_neg_even & a ~= 0
  Fp.one(2) = n_neg_even_one(n, a, b, x);
  Fp.two(2) = n_neg_even_two(n, a, b, x);
  % ---------------------------------
  % case 3: n_is_nonpos_half & a ~= 0
  Fp.one(3) = n_nonpos_half(n, a, b, x);
  Fp.two(3) = Fp.one(3);
  % ---------------------------------
  % case 4: n_is_neg_odd & a ~= 0
  Fp.one(4) = n_neg_odd(n, a, b, x);
  Fp.two(4) = Fp.one(4);
  % ---------------------------------
  % case 5: n_is_nonneg_even & a ~= 0
  Fp.one(5) = n_nonneg_even_one(n, a, b, x);
  Fp.two(5) = n_nonneg_even_two(n, a, b, x);
  % ---------------------------------
  % case 6: n_is_nonneg_half & a ~= 0
  Fp.one(6) = n_nonneg_half(n, a, b, x);
  Fp.two(6) = Fp.one(6);
  % ---------------------------------
  % case 7: n_is_pos_odd & a ~= 0
  Fp.one(7) = n_pos_odd_one(n, a, b, x);
  Fp.two(7) = n_pos_odd_two(n, a, b, x);
  % ---------------------------------
  %% converting to piecewise
  for k = ["one" "two"]
    Fp.(k)(n, a, b, x) = branches2piecewise(Fp.(k), cases);
    dFp.(k) = @(dFp_args) handle_fun(Fp.(k), fp.(k), dFp_args);
  end
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
function Fp = n_neg_even_one(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using trig identities
  % - n is a negative even integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = -n/2;
  S = heaviside(k-1);
  %% term calculations
  K = nchoosek(N-1, k-1)/((-a)^S*(2*k-1));
  Term = K*cot(axb)^(2*k-1);
  %% integral calculation
  Fp = symsum(Term, k, 1, N);
end
% =
function Fp = n_neg_even_two(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using power-reducing formulas
  % - n is a negative even integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = (-n-2)/2;
  S = heaviside(k-1);
  Arg = [k; 0]-N-1/2;
  G = gamma(Arg).^[-1; S];
  %% term calculations
  K.sincos = (-1)^(k)*prod(G(1:2))*npermk(N, k)/(a^S*(n+2*k));
  K.cot = (-1)^(-N)*G(2)*factorial(N)/(2*a*sqrt(sympi));
  K.cot = subs(K.cot, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n+2*k-1)*cos(axb)^S;
  Term.cot = K.cot*cos(axb)/sin(axb);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N)+Term.cot;
end
% =
function Fp = n_nonpos_half(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n+1/2 is a non-positive integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = -n/2+[-1/2; -1; -1/2; 1/4; -1/4];
  N = [N; piecewise(isint(N(4)), N(4), ...
                    isint(N(5)), N(5))];
  assume(N(4:5), 'real');
  Arg = k-[N(1:2); k+[N(1:2); -3/4]; 1];
  S = [heaviside(Arg(6)); integer(-N(4:5))];
  G = gamma(Arg(1:5)).^[-1; 1; S(1); -S(1); 2];
  clearassum;
  %% term calculations
  elliptic_args = cell(2,1);
  elliptic_args{1} = sympi/4-axb/2;
  elliptic_args{2} = 2;
  K.sincos = prod(G(1:4))/(a^S(1)*(n+2*k));
  K.E = -sqrt(sym(2))*sympi*prod(G(3:4))*S(2)/(2*a*G(5));
  K.F = -sqrt(sym(2))*prod(G(3:5))*S(3)/(a*sympi);
  K.E = subs(K.E, k, 1);
  K.F = subs(K.F, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n+2*k-1)*cos(axb)^S(1);
  Term.E = K.E*ellipticE(elliptic_args{:});
  Term.F = K.F*ellipticF(elliptic_args{:});
  %% integral calculation
  Fp = sym.zeros(2,1);
  Fp(1) = symsum(Term.sincos, k, 1, N(6));
  Fp(2) = Term.E+Term.F;
  Fp = sum(Fp);
end
% =
function Fp = n_neg_odd(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n is a negative odd integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = (-n-1)/2;
  S = heaviside(k-1);
  Arg = [k; 0]-N+1/2;
  G = gamma(Arg).^[1; -S];
  %% term calculations
  K.sincos = (-1)^(k)*prod(G(1:2))/(a^S*(n+2*k)*npermk(N, k));
  K.log_csc_cot = (-1)^(-N-1)*sqrt(sympi)*G(2)/(a*factorial(N));
  K.log_csc_cot = subs(K.log_csc_cot, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n+2*k-1)*cos(axb)^S;
  Term.log_csc_cot = K.log_csc_cot*log(csc(axb)+cot(axb));
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N)+Term.log_csc_cot;
end
% =
function Fp = n_nonneg_even_one(n, a, b, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using trig identities
  % - n is a non-negative even integer
  % - a ~= 0
  % ----------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = n/2;
  S = heaviside(k-1);
  %% term calculations
  K.sin = (-1)^(N+k+1)*nchoosek(n, k-1)/(2^((n-1)*S)*a^S*(n-2*k+2));
  K.x = nchoosek(n, N)/2^n;
  Term.sin = K.sin*sin((n-2*k+2)*axb);
  Term.x = K.x*x;
  %% integral calculation
  Fp = symsum(Term.sin, k, 1, N)+Term.x;
end
% =
function Fp = n_nonneg_even_two(n, a, b, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using power-reducing formulas
  % - n is a non-negative even integer
  % - a ~= 0
  % ----------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = n/2;
  S = heaviside(k-1);
  Arg = [k; 0]-N+1/2;
  G = gamma(Arg).^[1; -S];
  %% term calculations
  K.sincos = (-1)^(k+1)*prod(G(1:2))/(a^S*npermk(N, k)*(n-2*k+1));
  K.x = (-1)^N*sqrt(sympi)*G(2)/factorial(N);
  K.x = subs(K.x, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n-2*k+1)*cos(axb)^S;
  Term.x = K.x*x;
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N)+Term.x;
end
% =
function Fp = n_nonneg_half(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n-1/2 is a non-negative integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  elliptic_args = cell(2,1);
  elliptic_args{1} = sympi/4-axb/2;
  elliptic_args{2} = 2;
  N = n/2+[0; -1/2; -1/2; -1/4; 1/4];
  N = [N; piecewise(isint(N(4)), N(4), ...
                    isint(N(5)), N(5))];
  assume(N(4:5), 'real');
  Arg = k-[N(1:2); k+[N(1:2); -3/4]; 1];
  S = [heaviside(Arg(6)); integer(N(4:5))];
  G = gamma(Arg(1:5)).^[-1; 1; S(1); -S(1); 2];
  clearassum;
  %% term calculations
  K.sincos = prod(G(1:4))/((-a)^S(1)*(n-2*k+1));
  K.E = sqrt(sym(2))*sympi*prod(G(3:4))*S(2)/(2*a*G(5));
  K.F = -sqrt(sym(2))*prod(G(3:5))*S(3)/(a*sympi);
  K.E = subs(K.E, k, 1);
  K.F = subs(K.F, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n-2*k+1)*cos(axb)^S(1);
  Term.E = K.E*ellipticE(elliptic_args{:});
  Term.F = K.F*ellipticF(elliptic_args{:});
  %% integral calculation
  Fp = sym.zeros(2,1);
  Fp(1) = symsum(Term.sincos, k, 1, N(6));
  Fp(2) = Term.E+Term.F;
  Fp = sum(Fp);
end
% =
function Fp = n_pos_odd_one(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using trig identities
  % - n is a positive odd integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = (n+1)/2;
  S = heaviside(k-1);
  %% term calculations
  K = (-1)^(k)*nchoosek(N-1, k-1);
  Term = K*cos(axb)^(2*k-1)/(a^S*(2*k-1));
  %% integral calculation
  Fp = symsum(Term, k, 1, N);
end
% =
function Fp = n_pos_odd_two(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - using power reducing formulas
  % - n is a positive odd integer
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = (n-1)/2;
  S = heaviside(k-1);
  Arg = [k; 0]-N-1/2;
  G = gamma(Arg).^[-1; S];
  %% term calculations
  K.sincos = (-1)^(k+1)*prod(G(1:2))*npermk(N, k)/(a^S*(n-2*k+1));
  K.cos = (-1)^N*G(2)*factorial(N)/(2*a*sqrt(sympi));
  K.cos = subs(K.cos, k, 1);
  Term.sincos = K.sincos*sin(axb)^(n-2*k+1)*cos(axb)^S;
  Term.cos = K.cos*cos(axb);
  %% integral calculation
  Fp = symsum(Term.sincos, k, 1, N)+Term.cos;
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
