function [F f tF dF sF cF] = tanh_int(n, a, b, x)
  % - formula for this integral:
  % -------------------
  %  /
  %  | tanh(a*x+b)^n dx
  %  /
  % -------------------
    
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
  fp(n, a, b, x) = tanh(a*x+b)^n;
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
  Fp(1) = tanh(b)^n*x;
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
    h = simplify(rewrite(h, 'sinhcosh'), IAC{:})+fp;
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
  coth_args = (sqrt(coth(axb))+[1; -1; 0]).^[1; -1; 1];
  N = -n/2+[0; 1/4; -1/2; -1/4];
  N = [N; piecewise(isint(N(1)), N(1), ...
                    isint(N(2)), N(2), ...
                    isint(N(3)), N(3), ...
                    isint(N(4)), N(4))];
  assume(N(1:4), 'real');
  Arg = [N(1:4); n; k-1];
  S = [integer(-Arg(1:4)); decimal(Arg(5)); heaviside(Arg(6))];
  clearassum;
  %% constant calculations
  K.coth = 1/(a^S(6)*(n+2*k-1));
  K.x = S(1);
  K.log_sinh = S(3)/a;
  K.log_coth = S(5)/(2*a);
  K.atan = (-1)^S(4)*S(5)/a;
  %% term calculations
  Term.coth = K.coth*coth(axb)^(-n-2*k+1);
  Term.x = K.x*x;
  Term.log_sinh = K.log_sinh*log(sinh(axb));
  Term.log_coth = K.log_coth*log(prod(coth_args(1:2)));
  Term.atan = K.atan*atan(coth_args(3));
  %% integral calculation
  Last = Term.x+Term.log_sinh+Term.log_coth+Term.atan;
  Fp = symsum(Term.coth, k, 1, N(5))+Last;
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
  tanh_args = (sqrt(tanh(axb))+[1; -1; 0]).^[1; -1; 1];
  N = n/2+[0; -1/4; -1/2; 1/4];
  N = [N; piecewise(isint(N(1)), N(1), ...
                    isint(N(2)), N(2), ...
                    isint(N(3)), N(3), ...
                    isint(N(4)), N(4))];
  assume(N(1:4), 'real');
  Arg = [N(1:4); n; k-1];
  S = [integer(Arg(1:4)); decimal(Arg(5)); heaviside(Arg(6))];
  clearassum;
  %% constant calculations
  K.tanh = 1/((-a)^S(6)*(n-2*k+1));
  K.x = S(1);
  K.log_cosh = S(3)/a;
  K.log_tanh = S(5)/(2*a);
  K.atan = (-1)^S(2)*S(5)/a;
  %% term calculations
  Term.tanh = K.tanh*tanh(axb)^(n-2*k+1);
  Term.x = K.x*x;
  Term.log_cosh = K.log_cosh*log(cosh(axb));
  Term.log_tanh = K.log_tanh*log(prod(tanh_args(1:2)));
  Term.atan = K.atan*atan(tanh_args(3));
  %% integral calculation
  Last = Term.x+Term.log_cosh+Term.log_tanh+Term.atan;
  Fp = symsum(Term.tanh, k, 1, N(5))+Last;
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
