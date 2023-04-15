function [F f tF dF sF cF] = coth_int(n, a, b, x)
  % - formula for this integral:
  % -------------------
  %  /
  %  | coth(a*x+b)^n dx
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
  % -------------------------------
  % - helper function for computing
  %   the persistent integrals
  % -------------------------------
  
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% function handles
  IAC = {'IgnoreAnalyticConstraints' true};
  func = cell(2,1);
  func{1} = @(arg) subs(arg, children(arg, 4), ...
                        order_branches(children(arg, 4), 4:-1:1));
  func{2} = @(arg) 1/coth(children(arg, 1));
  %% integration variables
  [n a b x] = deal(sym('n'), sym('a'), sym('b'), sym('x'));
  k = sym('k');
  mod_args = cell(2,1);
  mod_args{1} = [-n; -n/2+[0; -1/2; 1/2; -1/4; 1/4]];
  mod_args{2} = -mod_args{1};
  mod_args{3} = [1; -ones(5,1)];
  A = sym([-1; 1]);
  S = heaviside(k-1);
  sublist = [1/tanh(b)^n; 1./(A*a).^S; mod(mod_args{1:2:3})];
  subvals = [coth(b)^n; -1./(-A*a).^S; mod(mod_args{2:3})];
  %% integral calculations
  [Fp fp] = tanh_int(-n, a, b, x);
  Fp(n, a, b, x) = mapSymType(Fp, 'symsum', func{1});
  fp(n, a, b, x) = mapSymType(fp, 'tanh', func{2});
  Fp = subs(order_branches(Fp, [1 3 2]), sublist, subvals);
  fp = simplify(fp, IAC{:});
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
