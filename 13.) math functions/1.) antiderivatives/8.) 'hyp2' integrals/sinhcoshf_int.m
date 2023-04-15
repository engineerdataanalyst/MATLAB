function [F f tF dF sF cF] = sinhcoshf_int(a, b, alpha, beta, delta, epsilon, x)
  % - formula for this integral:
  % -------------------------------------------
  %  /
  %  |  alpha*sinh(a*x+b)+beta*cosh(a*x+b)
  %  | ------------------------------------- dx
  %  | delta*sinh(a*x+b)+epsilon*cosh(a*x+b)
  %  /
  % -------------------------------------------
    
  %% check the input arguments
  % check the argument classes
  arguments
    a sym = sym('a');
    b sym = sym('b');
    alpha sym = sym('alpha');
    beta sym = sym('beta');
    delta sym = sym('delta');
    epsilon sym = sym('epsilon');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {a b alpha beta delta epsilon x};
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
  [a b alpha beta delta epsilon x] = deal(sym('a'), sym('b'), ...
                                          sym('alpha'), sym('beta'), ...
                                          sym('delta'), sym('epsilon'), ...
                                          sym('x'));
  num = alpha*sinh(a*x+b)+beta*cosh(a*x+b);
  den = delta*sinh(a*x+b)+epsilon*cosh(a*x+b);
  fp(a, b, alpha, beta, delta, epsilon, x) = num/den;
  %% cases
  cases = [a == 0;
           a ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  Fp = sym.zeros(size(cases));
  %% integral calculations
  % --------------
  % case 1: a == 0
  Fp(1) = fp(0, b, alpha, beta, delta, epsilon, x)*x;
  % --------------
  % case 2: a ~= 0
  Fp(2) = a_not_zero(a, b, alpha, beta, delta, epsilon, x);
  % --------------
  %% converting to piecewise
  Fp(a, b, alpha, beta, delta, epsilon, x) = branches2piecewise(Fp, cases);
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
function Fp = a_not_zero(a, b, alpha, beta, delta, epsilon, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  axb = a*x+b;
  %% constant calculations (case 1: [delta == epsilon])
  K.one = sym.zeros(2,1);
  K.one(1) = (alpha-beta)/(4*a*delta);
  K.one(2) = (alpha+beta)/(2*delta);
  %% term calculations (case 1: [deta == epsilon])
  Term.one = sym.zeros(2,1);
  Term.one(1) = exp(-2*axb);
  Term.one(2) = x;
  %% integral calculation (case 1: [deta == epsilon])
  Fp.one = sum(K.one.*Term.one);
  %% constant calculations (case 2: [delta == -epsilon])
  K.two = sym.zeros(2,1);
  K.two(1) = -(alpha+beta)/(4*a*delta);
  K.two(2) = (alpha-beta)/(2*delta);
  %% term calculations (case 2: [delta == -epsilon])
  Term.two = sym.zeros(2,1);
  Term.two(1) = exp(2*axb);
  Term.two(2) = x;
  %% integral calculation (case 2: [delta == -epsilon])
  Fp.two = sum(K.two.*Term.two);
  %% constant calculations (case 3: [delta^2-epsilon^2 ~= 0])
  A = [epsilon delta; delta epsilon];
  B = [alpha; beta];
  K.three = A\B;
  %% term calculations (case 3: [delta^2-epsilon^2 ~= 0])
  Term.three = sym.zeros(2,1);
  Term.three(1) = log(delta*sinh(axb)+epsilon*cosh(axb))/a;
  Term.three(2) = x;
  %% integral calculation (case 3: [delta^2-epsilon^2 ~= 0])
  Fp.three = sum(K.three.*Term.three);
  %% integral calculation (converting to piecewise)
  Fp = piecewise(delta == epsilon,       Fp.one, ...
                 delta == -epsilon,      Fp.two, ...
                 delta^2-epsilon^2 ~= 0, Fp.three);
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
