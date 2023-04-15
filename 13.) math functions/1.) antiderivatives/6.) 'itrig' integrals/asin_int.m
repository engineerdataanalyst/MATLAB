function [F f tF dF sF cF] = asin_int(n, a, b, x)
  % - formula for this integral:
  % -------------------
  %  /
  %  | asin(a*x+b)^n dx
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
  fp(n, a, b, x) = asin(a*x+b)^n;
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
  Fp(1) = asin(b)^n*x;
  % --------------
  % case 2: a ~= 0
  Fp(2) = a_not_zero(n, a, b, x);
  % --------------
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
function Fp = a_not_zero(n, a, b, x)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - a ~= 0
  % ---------------------------------
  
  %% integration variables
  [k u] = deal(sym('k'), sym('u'));
  axb = a*x+b;
  S = heaviside(k-1);
  %% u-substitution
  U = asin(axb);
  I = int(U^n, x, 'Hold', true);
  Iu = changeIntegrationVariable(I, U, u);
  Iu = factor_constants(Iu);
  %% integral calculation
  func = @(~) cosx_int(n, 1, 0, u);
  Fu = mapSymType(Iu, 'int', func);
  %% back substituting for x
  Sin = axb;
  Cos = sqrt(1-axb^2);
  Fp = subs(Fu, [sin(u) cos(u)], [Sin Cos]);
  Fp = subs(Fp, u, U);
  %% modifying the integral (a factor)
  [expr cond] = branches(Fp);
  for p = 1:4
    % part 1
    Children = sym(children(expr{p}));
    Children = sum(Children(1)*children(Children(2)));
    % part 2
    sublist = findSymType(Children, 'symsum');
    subvals = sublist;
    for t = 1:2
      Term = children(subvals(t), 1)/a^S;
      subvals(t) = a*subs(subvals(t), children(subvals(t), 1), Term);
    end
    expr{p} = sum(subs(Children, sublist, subvals));
  end
  %% modifying the integral (converting back to piecewise)
  Fp = branches2piecewise(expr, cond);
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
