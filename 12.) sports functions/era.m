function average = era(er, ip)
  % ----------------------------
  % - earned run average formula
  %   used in MLB
  % ----------------------------

  %% convert symbolic function arguments to sym
  narginchk(2,2);
  args = {};
  if issymfun(er)
    args(end+1) = {argnames(er)};
    er = formula(er);
  end
  if issymfun(ip)
    args(end+1) = {argnames(ip)};
    ip = formula(ip);
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
  if (~isnumeric(er) && ~issym(er)) || ...
     (~isnumeric(ip) && ~issym(ip))     
    str = stack('input arguments must be', ...
                'numeric or symbolic arrays');
    error(str);
  end
  if ~isequaldim(er, ip) && ...
    (~isscalar(er) && ~isscalar(ip))
    str = stack('input arguments must have', ...
                'the same array dimensions', ...
                'or be scalars');
    error(str);
  end
  %% earned run average formula
  average = er./ip*9;
  if convert2symfun
    average(args) = average;
  end
