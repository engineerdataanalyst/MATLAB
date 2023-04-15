function val = inrangei(x, range)
  % -----------------------
  % - the in range function
  %   for integer values
  % -----------------------

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
    val(isint(x) & range(1) <= x & x <= range(2)) = 1;
    val(~isint(x) | range(1) > x | x > range(2)) = 0;
  elseif (isnumeric(x) || all(issymnum(x), 'all')) && ...
         (isnumeric(range) || all(issymnum(range), 'all'))
    if issym(x)
      x = double(x);
    elseif issym(range)
      range = double(range);
    end
    val = sym(inrange(x, range));
  else
    val = sym.zeros(size(x));
    for k = 1:numel(x)
      val(k) = piecewise(isint(x(k)) & ...
                         range(1) <= x(k) & x(k) <= range(2), 1, 0);
    end
    if x_is_symfun || range_is_symfun
      val(x_args) = val;
    end
  end
