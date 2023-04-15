function val = point(x)
  % --------------------
  % - the point function
  % --------------------
  narginchk(1,1);
  if isnumeric(x)
    val = x;
    val(x == 0) = 1;
    val(x ~= 0) = 0;
  elseif issym(x)
    if all(issymnum(x), 'all')
      x = double(x);
      val = sym(point(x));
    elseif isscalar(x)
      val = piecewise(x == 0, 1, 0);
    else
      str = stack('symbolic expression', ...
                  'must be a scalar');
      error(str);
    end
  else
    str = stack('input argument must be', ...
                'a numeric or symbolic expression');
    error(str);
  end
