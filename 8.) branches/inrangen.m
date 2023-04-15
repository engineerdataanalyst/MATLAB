function val = inrangen(x, range)
  % ---------------------------
  % - the in range nan function
  % ---------------------------

  %% check the input arguments
  narginchk(2,2);
  if issymfun(x)
    x_is_symfun = true;
    x_args = argnames(x);
    x = formula(x);
  else
    x_is_symfun = false;
  end
  if issymfun(range)
    range_is_symfun = true;
    range_args = argnames(range);
    range = formula(range);
  else
    range_is_symfun = false;
  end
  if x_is_symfun && range_is_symfun && ~isequal(x_args, range_args)
    error(message('symbolic:symfun:InputMatch'));
  end
  if ~isnumeric(x) && ~issym(x)
    str = stack('first argument must be', ...
                'a numeric or symbolic expression');
    error(str);
  end
  if ~isnumvector(range, 'Len', 2) && ~issymvector(range, 'Len', 2)
    str = stack('second argument must be', ...
                'a numeric or symbolic vector', ...
                'of length 2');
    error(str);
  end
  %% return the value
  if isnumeric(x) && isnumeric(range)
    val = x;
    val(range(1) <= x & x <= range(2)) = 1;
    val(range(1) > x | x > range(2)) = nan;
  elseif (isnumeric(x) || all(issymnum(x(:)))) && ...
         (isnumeric(range) || all(issymnum(range(:))))
    if issym(x)
      x = double(x);
    elseif issym(range)
      range = double(range);
    end
    val = sym(inrange(x, range));
  else
    val = sym.zeros(size(x));
    for k = 1:numel(x)
      val(k) = piecewise(range(1) <= x(k) & x(k) <= range(2), 1);
    end
    if x_is_symfun || range_is_symfun
      val(x_args) = val;
    end
  end
