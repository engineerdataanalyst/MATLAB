function [F f tF dF sF cF] = quad3logB_int(n, a, b, c, B, x, options)
  % - formula for this integral:
  % ----------------------------
  %  /
  %  | n*logB(a*x^2+b*x+c, B) dx
  %  /
  % ----------------------------
  % - using these methods:
  %   1.) trig/hyperbolic substitution
  %   2.) partial fractions
    
  %% check the input arguments
  % check the argument classes
  arguments
    n sym = sym('n');
    a sym = sym('a');
    b sym = sym('b');
    c sym = sym('c');
    B sym = sym('B');
    x sym = sym('x');
    options.Method ...
    {mustBeText, mustBeMemberi(options.Method, ["one" "two"])};
  end
  % check the argument dimensions
  args = {n a b c B x};
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
      [F.(k) f.(k) tF.(k) dF.(k) sF.(k) cF.(k)] = quad3logB_int(Args{:});
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

  %% integrand
  [n a b c B x] = deal(sym('n'), sym('a'), sym('b'), sym('c'), ...
                       sym('B'), sym('x'));
  fp(n, a, b, c, B, x) = n*logB(a*x^2+b*x+c, B);
  fp = default_struct('one', 'two', 'Default', fp);
  %% assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% integral calculation
  Disc = disc(a, b, c); % b^2-4*a*c
  Fp = B_not_zero_or_one(n, a, b, c, B, x, Disc);
  %% converting to piecewise
  for k = ["one" "two"]
    Fp.(k)(n, a, b, c, B, x) = Fp.(k);
    dFp.(k) = @(dFp_args) handle_fun(Fp.(k), fp.(k), dFp_args);
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
function Fp = B_not_zero_or_one(n, a, b, c, B, x, Disc)
  % ---------------------------------
  % - helper function for calculating
  %   the persistent integral
  %   for the following case:
  % - B ~= 0 & B ~= 1
  % --------------------------------
  
  %% integration by parts
  func = @(arg) partfrac(children(arg, 1));
  func = @(arg) split_body(int(func(arg), x, 'Hold', true));
  I = int(n*logB(a*x^2+b*x+c, B), x, 'Hold', true);
  I = integrateByParts(I, 1);
  I = mapSymType(I, 'int', func);
  sublist = children(I, 2);
  subvals = release(sublist);
  I = subs(I, sublist, subvals);
  I = combine(I, 'int');
  %% integral calculation
  alpha = b*n/log(B);
  beta = 2*c*n/log(B);
  func = @(~) quad1rat_int(-1, a, b, c, alpha, beta, x, Method='one');
  Fp.one = mapSymType(I, 'int', func);
  Fp.two = Fp.one;
  %% modifying the integral (method one: [part 1])
  sublist = 2*a*beta-alpha*b;
  subvals = subs(sublist, log(B), 1)/log(B);
  Fp.one = subs(Fp.one, sublist, subvals);
  %% modifying the integral (method one: [part 2])
  [expr cond] = branches(Fp.one);
  expr{4} = Simplify(expr{4}, [2 4], 'Separate', false);
  expr{4} = Simplify(expr{4}, 3);
  expr{5} = Simplify(expr{5}, [2 4], 'Separate', false);
  expr{5} = Simplify(expr{5}, 2);
  Fp.one = branches2piecewise(expr, cond);
  %% modifying the integral (method two: [part 1])
  Fp.two = Fp.one;
  Fp.two = remove_branches(Fp.two, 5);
  Fp.two = subs(Fp.two, Disc > 0, Disc ~= 0);
  %% modifying the integral (method two: [part 2])
  arg = prod((2*a*x+b+[1; -1]*sqrt(Disc)).^[1; -1]);
  sublist = findSymType(Fp.two, 'atanh');
  subvals = log(arg)/2;
  Fp.two = subs(Fp.two, sublist, subvals);
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
