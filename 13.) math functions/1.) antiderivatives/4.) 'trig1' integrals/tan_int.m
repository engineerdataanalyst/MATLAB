function [F f tF dF sF cF] = tan_int(n, a, b, x)
  % - formula for this integral:
  % ------------------
  %  /
  %  | tan(a*x+b)^n dx
  %  /
  % ------------------
    
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
  fp(n, a, b, x) = tan(a*x+b)^n;
  %% cases
  n_is_neg = isint(2*n, 'Type', 'negative');
  n_is_nonneg = isint(2*n, 'Type', 'positive or zero');
  cases = [a == 0;
           n_is_neg & a ~= 0;
           n_is_nonneg & a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  % ----------------------------
  % case 1: a == 0
  Fp(1) = tan(b)^n*x;
  % ----------------------------
  % case 2: n_is_neg & a ~= 0
  Fp(2) = n_neg(n, a, b, x);
  % ----------------------------
  % case 3: n_is_nonneg & a ~= 0
  Fp(3) = n_nonneg(n, a, b, x);
  % ----------------------------
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
    h = simplify(rewrite(h, 'sincos'), IAC{:})+fp;
  else
    h = fp(dFp_args{:});
  end
end
% =
function Fp = n_neg(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case
  % - 2*n is a negative integer
  % - a ~= 0
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  cot_args = sqrt(sym(2))*(cot(axb)+[-1; 1])/(2*sqrt(cot(axb)));
  N = -n/2+[0; 1/4; -1/2; -1/4];
  N = [N; piecewise(isint(N(1)), N(1), ...
                    isint(N(2)), N(2), ...
                    isint(N(3)), N(3), ...
                    isint(N(4)), N(4))];
  assume(N(1:4), 'real');
  Arg = [N(1:4); n; k-1];
  S = [integer(-Arg(1:4)); decimal(Arg(5)); heaviside(Arg(6))];
  Neg1 = 1./(-1).^(N(2)-(1-S(2))/2+[0; S(2)]);
  clearassum;
  %% constant calculations
  K.cot = (-1)^(k+1)/(a^S(6)*(n+2*k-1));
  K.x = (-1)^-N(1)*S(1);
  K.log_sin = (-1)^-N(3)*S(3)/a;
  K.acot = Neg1(1)*sqrt(sym(2))*S(5)/(2*a);
  K.acoth = Neg1(2)*sqrt(sym(2))*S(5)/(2*a);
  %% term calculations
  Term.cot = K.cot*cot(axb)^(-n-2*k+1);
  Term.x = K.x*x;
  Term.log_sin = K.log_sin*log(sin(axb));
  Term.acot = K.acot*acot(cot_args(1));
  Term.acoth = K.acoth*acoth(cot_args(2));
  %% integral calculation
  Last = Term.x+Term.log_sin+Term.acot+Term.acoth;
  Fp = symsum(Term.cot, k, 1, N(5))+Last;
end
% =
function Fp = n_nonneg(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case
  % - 2*n is a non-negative integer
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  tan_args = sqrt(sym(2))*(tan(axb)+[-1; 1])/(2*sqrt(tan(axb)));
  N = n/2+[0; -1/4; -1/2; 1/4];
  N = [N; piecewise(isint(N(1)), N(1), ...
                    isint(N(2)), N(2), ...
                    isint(N(3)), N(3), ...
                    isint(N(4)), N(4))];
  assume(N(1:4), 'real');
  Arg = [N(1:4); n; k-1];
  S = [integer(Arg(1:4)); decimal(Arg(5)); heaviside(Arg(6))];
  Neg1 = (-1).^(N(2)+(1-S(2))/2+[0; S(2)]);
  clearassum;
  %% constant calculations
  K.tan = (-1)^(k+1)/(a^S(6)*(n-2*k+1));
  K.x = (-1)^(N(1))*S(1);
  K.log_cos = (-1)^(N(3)+1)*S(3)/a;
  K.atan = Neg1(1)*sqrt(sym(2))*S(5)/(2*a);
  K.atanh = Neg1(2)*sqrt(sym(2))*S(5)/(2*a);
  %% term calculations
  Term.tan = K.tan*tan(axb)^(n-2*k+1);
  Term.x = K.x*x;
  Term.log_cos = K.log_cos*log(cos(axb));
  Term.atan = K.atan*atan(tan_args(1));
  Term.atanh = K.atanh*atanh(tan_args(2));
  %% integral calculation
  Last = Term.x+Term.log_cos+Term.atan+Term.atanh;
  Fp = symsum(Term.tan, k, 1, N(5))+Last;
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
