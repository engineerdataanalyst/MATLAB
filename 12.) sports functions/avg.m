function average = avg(h, ab)
  % -------------------------
  % - batting average formula
  %   used in MLB
  % -------------------------

  %% convert symbolic function arguments to sym
  narginchk(2,2);
  args = {};
  if issymfun(h)
    args(end+1) = {argnames(h)};
    h = formula(h);
  end
  if issymfun(ab)
    args(end+1) = {argnames(ab)};
    ab = formula(ab);
  end
  if ~isallequal(args)
    error(message('symbolic:symfun:InputMatch'));
  end
  if ~isempty(args)
    convert2symfun = true;
    args = args{1};
  else
    convert2symfun = false;
  end
  %% check the input arguments
  if (~isnumeric(h) && ~issym(h)) || ...
     (~isnumeric(ab) && ~issym(ab))     
    str = stack('input arguments must be', ...
                'numeric or symbolic arrays');
    error(str);
  end
  if ~isequaldim(h, ab) && ...
    (~isscalar(h) && ~isscalar(ab))
    str = stack('input arguments must have', ...
                'the same array dimensions', ...
                'or be scalars');
    error(str);
  end
  %% slugging percentage formula
  average = h./ab;
  if convert2symfun
    average(args) = average;
  end
