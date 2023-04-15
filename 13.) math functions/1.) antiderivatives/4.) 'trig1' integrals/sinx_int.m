function [F f tF dF sF cF] = sinx_int(n, a, b, x)
  % - formula for this integral:
  % --------------------------
  %  /
  %  | (a*x+b)^n*sin(a*x+b) dx
  %  /
  % --------------------------
  
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
  fp(n, a, b, x) = (a*x+b)^n*sin(a*x+b);
  %% cases
  n_is_neg_int = isint(n, 'Type', 'negative');
  n_is_nonpos_half = isint(n+1/2, 'Type', 'negative or zero');
  n_is_nonneg_int = isint(n, 'Type', 'positive or zero');
  n_is_nonneg_half = isint(n-1/2, 'Type', 'positive or zero');
  cases = [a == 0;
           n_is_neg_int & a ~= 0;
           n_is_nonpos_half & a ~= 0;
           n_is_nonneg_int & a ~= 0;
           n_is_nonneg_half & a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  % ---------------------------------
  % case 1: a == 0
  Fp(1) = b^n*sin(b)*x;
  % ---------------------------------
  % case 2: n_is_neg_int & a ~= 0
  Fp(2) = n_neg_int(n, a, b, x);
  % ---------------------------------
  % case 3: n_is_nonpos_half & a ~= 0
  Fp(3) = n_nonpos_half(n, a, b, x);
  % ---------------------------------
  % case 4: n_is_nonneg_int & a ~= 0
  Fp(4) = n_nonneg_int(n, a, b, x);
  % ---------------------------------
  % case 5: n_is_nonneg_half & a ~= 0
  Fp(5) = n_nonneg_half(n, a, b, x);
  % ---------------------------------
  %% converting to piecewise
  Fp(n, a, b, x) = branches2piecewise(Fp, cases);
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
function Fp = n_neg_int(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 2:
  % - n is a negative integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N.sin = piecewise(isodd(n),  -n/2-1/2, ...
                    iseven(n), -n/2);
  N.cos = piecewise(isodd(n),  -n/2-1/2, ...
                    iseven(n), -n/2-1);
  P = -expression(N.sin)+[0; 1];
  Arg = [k-1; P];
  assume(Arg(2:3), 'real');
  S = [heaviside(Arg(1)); integer(Arg(2:3))];
  clearassum;
  %% term calculations
  K.sin = (-1)^k/(a^S(1)*npermk(-n-1, 2*k-1));
  K.cos = (-1)^k/(a^S(1)*npermk(-n-1, 2*k));
  K.sinint = (-1)^P(1)*S(2)/(a*factorial(-n-1));
  K.cosint = (-1)^P(2)*S(3)/(a*factorial(-n-1));
  Term.sin = K.sin*axb^(n+2*k-1)*sin(axb);
  Term.cos = K.cos*axb^(n+2*k)*cos(axb);
  Term.sinint = K.sinint*sinint(axb);
  Term.cosint = K.cosint*cosint(axb);
  %% integral calculation
  Fp = sym.zeros(2,1);
  Fp(1) = symsum(Term.sin, k, 1, N.sin)+symsum(Term.cos, k, 1, N.cos);
  Fp(2) = Term.sinint+Term.cosint;
  Fp = sum(Fp);
end
% =
function Fp = n_nonpos_half(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 3:
  % - n+1/2 a non-positive integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  fresnel_arg = sqrt(sym(2))*sqrt(axb)/sqrt(sympi);
  N.sin = piecewise(isint(-n/2-1/4), -n/2-1/4, ...
                    isint(-n/2+1/4), -n/2+1/4);
  N.cos = piecewise(isint(-n/2-3/4), -n/2-3/4, ...
                    isint(-n/2-1/4), -n/2-1/4);
  P = -expression(N.sin);
  Arg = [k-1; P; n+[1; 2*k+[0; 1]]];
  assume(Arg(2:3), 'real');
  S = [heaviside(Arg(1)); integer(Arg(2:3))];
  G = gamma(Arg(4:6));
  clearassum;
  %% term calculations
  K.sin = (-1)^(k+1)*G(1)^S(1)/(a^S(1)*G(2));
  K.cos = (-1)^k*G(1)^S(1)/(a^S(1)*G(3));
  K.Fs = (-1)^P(1)*sqrt(sym(2))*G(1)*S(2)/a;
  K.Fc = (-1)^P(2)*sqrt(sym(2))*G(1)*S(3)/a;
  Term.sin = K.sin*axb^(n+2*k-1)*sin(axb);
  Term.cos = K.cos*axb^(n+2*k)*cos(axb);
  Term.Fs = K.Fs*fresnels(fresnel_arg);
  Term.Fc = K.Fc*fresnelc(fresnel_arg);
  %% integral calculation
  Fp = sym.zeros(2,1);
  Fp(1) = symsum(Term.sin, k, 1, N.sin)+symsum(Term.cos, k, 1, N.cos);
  Fp(2) = Term.Fs+Term.Fc;
  Fp = sum(Fp);
end
% =
function Fp = n_nonneg_int(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 4:
  % - n is a non-negative integer
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  N = piecewise(iseven(n), n/2+1, ...
                isodd(n),  n/2+1/2);
  S = heaviside(k-1);
  %% term calculations
  K.sin = (-1)^(k+1)*npermk(n, 2*k-1)/a^S;
  K.cos = (-1)^k*npermk(n, 2*k-2)/a^S;
  Term.sin = K.sin*axb^(n-2*k+1)*sin(axb);
  Term.cos = K.cos*axb^(n-2*k+2)*cos(axb);
  %% integral calculation
  Fp = symsum(Term.sin, k, 1, N)+symsum(Term.cos, k, 1, N);
end
% =
function Fp = n_nonneg_half(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for case 5:
  % - n-1/2 is a non-negative integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  fresnel_arg = sqrt(sym(2))*sqrt(axb)/sqrt(sympi);
  N.sin = piecewise(isint(n/2-1/4), n/2-1/4, ...
                    isint(n/2+1/4), n/2+1/4);
  N.cos = piecewise(isint(n/2+3/4), n/2+3/4, ...
                    isint(n/2+1/4), n/2+1/4);
  P = 3*n/2+[3/4 1/4];
  Arg = [k-1; expression(N.sin, [2 1]); -n+[2*k+[-1; -2]; 0]];
  assume(Arg(2:4), 'real');
  S = [heaviside(Arg(1)); integer(Arg(2:3))];
  G = gamma(Arg(4:6));
  clearassum;
  %% term calculations
  K.sin = (-1)^k*G(1)^S(1)/(a*G(3))^S(1);
  K.cos = (-1)^k*G(2)^S(1)/(a*G(3))^S(1);
  K.Fs = (-1)^P(1)*sqrt(sym(2))*sympi*S(2)/(a*G(3));
  K.Fc = (-1)^P(2)*sqrt(sym(2))*sympi*S(3)/(a*G(3));
  Term.sin = K.sin*axb^(n-2*k+1)*sin(axb);
  Term.cos = K.cos*axb^(n-2*k+2)*cos(axb);
  Term.Fs = K.Fs*fresnels(fresnel_arg);
  Term.Fc = K.Fc*fresnelc(fresnel_arg);
  %% integral calculation
  Fp = sym.zeros(2,1);
  Fp(1) = symsum(Term.sin, k, 1, N.sin)+symsum(Term.cos, k, 1, N.cos);
  Fp(2) = Term.Fs+Term.Fc;
  Fp = sum(Fp);
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
