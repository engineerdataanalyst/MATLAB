function [F f tF dF sF cF] = sechtanh_int(n, p, a, b, x)
  % - formula for this integral:
  % ---------------------------------
  %  /
  %  | sech(a*x+b)^n*tanh(a*x+b)^n dx
  %  /
  % ---------------------------------
    
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    p sym = sym('p');
    a sym = sym('a');
    b sym = sym('b');
    x sym = sym('x');
  end
  % check the argument dimensions
  args = {n p a b x};
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
  %% integral calculations
  IAC = {'IgnoreAnalyticConstraints' true};
  [n p a b x] = deal(sym('n'), sym('p'), sym('a'), sym('b'), sym('x'));
  [Fp fp.non_handle] = sinhcosh_int(p, -(n+p), a, b, x);
  Fp(n, p, a, b, x) = Fp;
  fp.non_handle(n, p, a, b, x) = fp.non_handle;
  fp.handle = @(dFp_args) handle_fun(Fp, fp, dFp_args, "fp");
  dFp = @(dFp_args) handle_fun(Fp, fp, dFp_args, "dFp");
  dFp = @(dFp_args) dFp(dFp_args)-fp.handle(dFp_args);
  dFp = @(dFp_args) simplify(dFp(dFp_args), IAC{:})+ ...
                             fp.non_handle(dFp_args{:});
  %% integral modifications (part 1)
  % ...code for integral modifications coming soon!!!!
end
% =
function h = handle_fun(Fp, fp, dFp_args, h_type)
  % ---------------------------------
  % - helper function for computing
  %   the persistent function handles
  % ---------------------------------
  IAC = {'IgnoreAnalyticConstraints' true};
  switch h_type
    case "fp"
      h = rewrite(fp.non_handle, 'sinhcosh');
      h = simplify(h, IAC{:});
      h = h(dFp_args{:});
    case "dFp"
      func = @(arg, var) diff(rewrite(arg, 'sinhcosh'), var);
      h = arrayfun(func, Fp(dFp_args{:}), dFp_args{end});
      h = simplify(h, IAC{:});
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
  for k = 1:numel(F)
    % ---------------------------------
    % symbolic function arguments
    Fp_args = num2cell(argnames(Fp));
    fp_non_handle = @(args) fp.non_handle(args{:}); %#ok<NASGU>
    [F_args argsk] = deal(cell2array(args, k));
    Vars2Exclude = sym(cellfun(@symvar, F_args(1:end-1), uniform{:}));
    Defaults = F_args{end};
    Args = {'Vars2Exclude' Vars2Exclude 'Defaults' Defaults};
    F_args{end} = randsym(Args{:});
    if ~isequal(F_args, Fp_args)
      rhs.Fp = Fp(F_args{:});
      rhs.fp.non_handle = fp.non_handle(F_args{:});
    else
      rhs.Fp = Fp;
      rhs.fp.non_handle = fp.non_handle;
    end
    % ---------------------------------
    % symbolic function calculation
    vars = argsk(1:end-1);
    vars = sym(cellfun(@symvar, vars, uniform{:}));
    vars = unique(vars, 'stable');
    vars_str = join(string(vars), ",");
    if ~isempty(vars)
      F{k}(vars) = rhs.Fp;
      f{k}(vars) = rhs.fp.non_handle;
      at = "@("+vars_str+")";
      F_str = "F{%d}("+vars_str+")";
      dFp_args = "cellsubs(F_args,vars,{"+vars_str+"})";
    else
      F{k} = rhs.Fp;
      f{k} = rhs.fp.non_handle;
      at = "@()";
      F_str = "F{%d}";
      dFp_args = "F_args";
    end
    dFp_str = "dFp("+dFp_args+")";
    fp_non_handle_str = "fp_non_handle("+dFp_args+")";
    % ---------------------------------
    % test function handle strings
    tF_str = at+dFp_str+"-"+fp_non_handle_str;
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
