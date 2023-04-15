function [F f tF dF sF cF] = csc_int(n, a, b, x, options)
  % - formula for this integral:
  % ------------------
  %  /
  %  | csc(a*x+b)^n dx
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
      [F.(k) f.(k) tF.(k) dF.(k) sF.(k) cF.(k)] = csc_int(Args{:});
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
  
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% integration variables
  [n a b x] = deal(sym('n'), sym('a'), sym('b'), sym('x'));
  k = sym('k');
  N = -(n+1)/2;
  A = [-1; 1];
  B = n+2*k-1;
  S = heaviside(k-1);
  sublist = [1./((A*a).^S*B); (-1).^([N+[0; 1/2]; k-n/2+1])];
  subvals = [-1./((-A*a).^S*B); 1./sublist(3:4); (-1)^(k+n/2+1)];
  %% integral calculations
  [Fp fp] = sin_int(-n, a, b, x);
  for p = ["one" "two"]
    Fp.(p)(n, a, b, x) = order_branches(Fp.(p), [1 7:-1:5 3:4 2]);
    fp.(p)(n, a, b, x) = fp.(p);
    if p == "one"
      Fp.(p) = subs(Fp.(p), sublist([1:3 5]), subvals([1:3 5]));
    else
      Fp.(p) = subs(Fp.(p), sublist(1:4), subvals(1:4));
    end
    dFp.(p) = @(dFp_args) handle_fun(Fp.(p), fp.(p), dFp_args);
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
