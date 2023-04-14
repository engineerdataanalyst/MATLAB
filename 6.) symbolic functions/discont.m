function dc = discont(a, options)
  % ------------------------------
  % - computes the discontinuities
  %   of a symbolic scalar
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["pw" "all"])} = "all";
    options.Var sym;
  end
  % check the symbolic array
  if ~issymscalar(a)
    error('''a'' must be a symbolic scalar');
  end
  % check the discontinuity mode
  Mode = lower(options.Mode);
  % check the discontinuity variable
  if isfield(options, 'Var')
    x = options.Var;
  else
    x = symvar(a, 1);
    if isempty(x)
      x = sym('x');
    end
  end  
  if ~issymvarscalar(x)
    error('''x'' must be a symbolic variable scalar');
  end
  %% compute the discontinuities
  dc = feval(symengine, 'discont', a, x);
  dc = Str2sym(string(dc));
  if Mode == "pw"
    expr = branches(a);
    expr_dc = cell(size(expr));
    for k = 1:length(expr)
      expr_dc{k} = feval(symengine, 'discont', expr{k}, x);
    end
    expr_dc = sym(convert2col(expr_dc)).';
    dc(symismember(dc, expr_dc)) = [];
  end
