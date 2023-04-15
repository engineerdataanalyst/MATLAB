function [F f tF dF sF cF] = quad2rat_int(a, b, c, alpha, beta, x, options)
  % - formula for this integral:
  % --------------------------------------
  %  /
  %  | (alpha*x^2+beta)/(a*x^4+b*x^2+c) dx
  %  /
  % --------------------------------------
  % - using these methods:
  %   1.) inverse trig/hyperbolic functions
  %   2.) partial fractions
  
  %% check the input arguments
  % check the argument classes
  arguments
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
  args = {a b c alpha beta x};
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
      [F.(k) f.(k) tF.(k) dF.(k) sF.(k) cF.(k)] = quad2rat_int(Args{:});
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

  %% integration
  [a b c alpha beta x] = deal(sym('a'), sym('b'), sym('c'), ...
                              sym('alpha'), sym('beta'), sym('x'));
  fp(a, b, c, alpha, beta, x) = (alpha*x^2+beta)/(a*x^4+b*x^2+c);
  fp = default_struct('one', 'two', 'Default', fp);
  %% cases
  cases = [b == 0 & a == 0 & c ~= 0;
           b == 0 & c == 0 & a ~= 0;
           b ~= 0 & a == 0;
           b ~= 0 & c == 0;
           a ~= 0 & c ~= 0];
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  [Fp.one Fp.two] = deal(sym.zeros(size(cases)));
  %% integral calculations
  % --------------------------------
  % case 1: b == 0 & a == 0 & c ~= 0
  Fp.one(1) = ba_zero_c_not_zero(c, alpha, beta, x);
  Fp.two(1) = Fp.one(1);
  % --------------------------------
  % case 2: b == 0 & c == 0 & a ~= 0
  Fp.one(2) = bc_zero_a_not_zero(a, alpha, beta, x);
  Fp.two(2) = Fp.one(2);
  % --------------------------------
  % case 3: b ~= 0 & a == 0
  S = b_not_zero_a_zero(b, c, alpha, beta, x);
  Fp.one(3) = S.one;
  Fp.two(3) = S.two;
  % --------------------------------
  % case 4: b ~= 0 & c == 0
  S = b_not_zero_c_zero(a, b, alpha, beta, x);
  Fp.one(4) = S.one;
  Fp.two(4) = S.two;
  % --------------------------------
  % case 5: a ~= 0 & c ~= 0
  S = ac_not_zero(a, b, c, alpha, beta, x);
  Fp.one(5) = S.one;
  Fp.two(5) = S.two;
  % --------------------------------
  %% converting to piecewise
  for k = ["one" "two"]
    Fp.(k)(a, b, c, alpha, beta, x) = branches2piecewise(Fp.(k), cases);
    dFp.(k) = @(dFp_args) handle_fun(Fp.(k), fp.(k), dFp_args);
  end
end
% =
function Fp = ba_zero_c_not_zero(c, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - b == 0 & a == 0 & c ~= 0
  % ---------------------------------
  integrand = alpha*x^2/c+beta/c;
  Fp = int(integrand, x);
  Fp = expand(Fp);
end
% =
function Fp = bc_zero_a_not_zero(a, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - b == 0 & c == 0 & a ~= 0
  % ---------------------------------
  integrand = alpha/(a*x^2)+beta/(a*x^4);
  Fp = int(integrand, x);
  Fp = expand(Fp);
end
% =
function Fp = b_not_zero_a_zero(b, c, alpha, beta, x)
  % ----------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - b ~= 0 & a == 0
  % ----------------------------------
  
  %% assumptions
  K = b*beta-alpha*c;
  assume([K b] ~= 0);
  cleanup = onCleanup(@() clearassum);
  %% integration variables
  Cell = cell(2,1);
  Cell{1} = sym([0 1 0 0 0 alpha/b]);
  Cell{2} = sym([-1 b 0 c 0 K/b]);
  [N A B C Alpha Beta] = components2vector(Cell{:});
  %% integral calculation
  Fp = quad1rat_int(N, A, B, C, Alpha, Beta);
  Kold = children(expression(Fp.one{2}, 2), [1 3:4]);
  Kold = prod(sym(Kold));
  Knew = K/(1i*b^(3/2)*sqrt(c));
  func = @(~) atanh(sqrt(b)*x/(1i*sqrt(c)))*Knew/Kold;
  Fp.one{2} = mapSymType(Fp.one{2}, 'atanh', func);
  for k = ["one" "two"]
    Fp.(k) = cellfun(@formula, Fp.(k));
    Fp.(k) = Simplify(sum(Fp.(k)), 'IgnoreAnalyticConstraints', true);
    Fp.(k) = SimplifyFraction(Fp.(k));
  end
end
% =
function Fp = b_not_zero_c_zero(a, b, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - b ~= 0 & c == 0
  % ---------------------------------
  
  %% assumptions
  K = alpha*b-a*beta;
  assume([K b] ~= 0);
  cleanup = onCleanup(@() clearassum);
  %% integration variables
  Cell = cell(2,1);
  Cell{1} = sym([-1 1 0 0 0 beta/b]);
  Cell{2} = sym([-1 a 0 b 0 K/b]);
  [N A B C Alpha Beta] = components2vector(Cell{:});
  %% integral calculation
  Fp = quad1rat_int(N, A, B, C, Alpha, Beta);
  Kold = children(expression(Fp.one{2}, 2), [1 3:4]);
  Kold = prod(sym(Kold));
  Knew = -K/(2i*b^(3/2)*sqrt(a));
  func = @(~) atanh(sqrt(a)*x/(1i*sqrt(b)))*Knew/Kold;
  Fp.one{2} = mapSymType(Fp.one{2}, 'atanh', func);
  for k = ["one" "two"]
    Fp.(k) = cellfun(@formula, Fp.(k));
    Fp.(k) = remove_branches(sum(Fp.(k)), 1);
    Fp.(k) = Simplify(Fp.(k), 'IgnoreAnalyticConstraints', true);
    Fp.(k) = SimplifyFraction(Fp.(k));
  end
end
% =
function Fp = ac_not_zero(a, b, c, alpha, beta, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - a ~= 0 & c ~= 0
  % ---------------------------------

  %% integration variables
  u = sym('u');
  one = sym([1; -1]);
  U = sqrt(a)*x-one*sqrt(c)/x;
  K = cell(2,1);
  K{1} = b+2*one*sqrt(a)*sqrt(c);
  K{2} = diff(U, x);
  K{3} = (alpha*sqrt(c)+one*beta*sqrt(a))/(2*sqrt(a)*sqrt(c));
  %% assumptions
  assume(2*sqrt(a)*sqrt(c)*K{3} ~= 0 & a ~= 0 & c ~= 0);
  cleanup = onCleanup(@() clearassum);
  %% integral calculation
  func = @(arg, uval) subs(arg, u, uval);
  U = num2cell(U);
  Fp = quad1rat_int(-1, 1, 0, K{1}, 0, K{3}, u);
  for k = ["one" "two"]
    Fp.(k) = cellfun(func, Fp.(k), U, 'UniformOutput', false);
    Fp.(k) = sum([Fp.(k){:}]);
    Fp.(k) = remove_branches(Fp.(k), 1);
    Fp.(k) = Simplify(Fp.(k), 'IgnoreAnalyticConstraints', true);
    Fp.(k) = SimplifyFraction(Fp.(k));
  end
end
% =
function h = handle_fun(Fp, fp, dFp_args)
  % ---------------------------------
  % - helper function for computing
  %   the persistent function handles
  % ---------------------------------
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
