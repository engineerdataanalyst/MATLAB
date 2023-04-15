function [F f tF dF sF cF] = logB_int(n, p, a, b, B, x)
  % - formula for this integral:
  % -----------------------------
  %  /
  %  | (a*x+b)^n*logB(a*x+b)^p dx
  %  /
  % -----------------------------
    
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
  fp(n, p, a, b, B, x) = (a*x+b)^n*log(a*x+b)^p/log(B)^p;
  %% cases
  p_is_neg_int = isint(p, 'Type', 'negative');
  p12_is_nonpos_int = isint(p+1/2, 'Type', 'negative or zero');
  p_is_nonneg_int = isint(p, 'Type', 'positive or zero');
  p12_is_nonneg_int = isint(p-1/2, 'Type', 'positive or zero');
  cases = [a == 0;
           n == -1 & a ~= 0;
           n ~= -1 & p_is_neg_int & a ~= 0;
           n ~= -1 & p12_is_nonpos_int & a ~= 0;
           n ~= -1 & p_is_nonneg_int & a ~= 0;
           n ~= -1 & p12_is_nonneg_int & a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  %% --------------------------------------------
  % case 1: a == 0
  Fp(1) = b^n*log(b)^p/log(B)^p*x;
  % --------------------------------------------
  % case 2: n == -1 & a ~= 0
  log_log_axb = log(B)*log(log(a*x+b));
  log_axb = log(B)^-p*log(a*x+b)^(p+1)/(p+1);
  Fp(2) = a^-1*piecewise(p == -1, log_log_axb, ...
                         p ~= -1, log_axb);
  % --------------------------------------------
  % case 3: n ~= -1 & p_is_neg_int & a ~= 0
  Fp(3) = p_neg_int(n, p, a, b, B, x);
  % --------------------------------------------
  % case 4: n ~= -1 & p12_is_nonpos_int & a ~= 0
  Fp(4) = p12_neg_int(n, p, a, b, B, x);
  % --------------------------------------------
  % case 5: n ~= -1 & p_is_nonneg_int & a ~= 0
  Fp(5) = p_nonneg_int(n, p, a, b, B, x);
  % --------------------------------------------
  % case 6: n ~= -1 & p12_is_nonneg_int & a ~= 0
  Fp(6) = p12_pos_int(n, p, a, b, B, x);
  % --------------------------------------------
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
function Fp = p_neg_int(n, p, a, b, B, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n ~= -1
  % - p is a negative integer
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  a_logB = ([-1; 1]*a*log(B)^p).^[heaviside(k-1); 1];
  %% term calculations
  neg1.log = (n+1)^(k-1)/(a_logB(1)*npermk(-p-1, k));
  neg1.ei = (n+1)^(-p-1)/(a_logB(2)*factorial(-p-1));
  term.log = neg1.log*axb^(n+1)*log(axb)^(p+k);
  term.ei = neg1.ei*ei((n+1)*log(axb));
  %% integral calculation
  Fp = symsum(term.log, k, 1, -p-1)+term.ei;
end
% =
function Fp = p12_neg_int(n, p, a, b, B, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n ~= -1
  % - p+1/2 is a non-positive integer
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  P = -p-1/2;
  Arg = [[k; 1]-1; [1; -1]*SignIm(n+1)];
  S = heaviside(Arg);
  A = (a*log(B)^p).^S(1:2);
  Sqrt = [1; 1i]*sqrt(n+1)*sqrt(log(axb));
  %% term calculations
  K.log = (-1)^(k+1)*(n+1)^(k-1)*gamma(p+1)^S(1)/(A(1)*gamma(p+k+1));
  K.erfi = (-1)^(p+1/2)*gamma(p+1)/(A(2)*(n+1)^(p+1));
  K.erf = subs(K.erfi, p+1/2, p-1/2)*1i;
  Term.log = K.log*axb^(n+1)*log(axb)^(p+k);
  Term.erfi = K.erfi*erfi(Sqrt(1))*S(3);
  Term.erf = K.erf*erf(Sqrt(2))*S(4);
  %% integral calculation
  Fp = symsum(Term.log, k, 1, P)+Term.erfi+Term.erf;
end
% =
function Fp = p_nonneg_int(n, p, a, b, B, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n ~= -1
  % - p is a non-negative integer
  % ---------------------------------
  
  %% integration variables
  k = sym('k');
  axb = a*x+b;
  K = (a*log(B)^p)^heaviside(k-1);
  %% term calculations
  neg1 = (-1)^(k+1)/(K*(n+1)^(k))*nchoosek(p, k-1)*factorial(k-1);
  term = neg1*axb^(n+1)*log(axb)^(p-k+1);
  %% integral calculation
  Fp = symsum(term, k, 1, p+1);
end
% =
function Fp = p12_pos_int(n, p, a, b, B, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - n ~= -1
  % - p-1/2 is a non-negative integer
  % ---------------------------------

  %% integration variables
  k = sym('k');
  axb = a*x+b;
  arg = [[k; 1]-1; [1; -1]*SignIm(n+1)];
  S = heaviside(arg);
  A = (a*log(B)^p).^S(1:2);
  Sqrt = [1; 1i]*sqrt(n+1)*sqrt(log(axb));
  %% term calculations
  K.log = gamma(k-p-1)/(A(1)*(n+1)^k*gamma(-p)^S(1));
  K.erfi = sympi/(A(2)*(n+1)^(p+1)*gamma(-p));
  K.erf = -K.erfi*1i;
  Term.log = K.log*axb^(n+1)*log(axb)^(p-k+1);
  Term.erfi = K.erfi*erfi(Sqrt(1))*S(3);
  Term.erf = K.erf*erf(Sqrt(2))*S(4);
  %% integral calculation
  Fp = symsum(Term.log, k, 1, p+1/2)+Term.erfi+Term.erf;
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
