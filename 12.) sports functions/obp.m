function percentage = obp(h, bb, hbp, sf, ab)
  % ----------------------------
  % - on-base percentage formula
  %   used in MLB
  % ----------------------------

  %% convert symbolic function arguments to sym
  narginchk(5,5);
  args = {};
  if issymfun(h)
    args(end+1) = {argnames(h)};
    h = formula(h);
  end
  if issymfun(bb)
    args(end+1) = {argnames(bb)};
    bb = formula(bb);
  end
  if issymfun(hbp)
    args(end+1) = {argnames(hbp)};
    hbp = formula(hbp);
  end
  if issymfun(sf)
    args(end+1) = {argnames(sf)};
    sf = formula(sf);
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
     (~isnumeric(bb) && ~issym(bb)) || ...
     (~isnumeric(hbp) && ~issym(hbp)) || ...
     (~isnumeric(sf) && ~issym(sf)) || ...
     (~isnumeric(ab) && ~issym(ab))
    str = stack('input arguments must be', ...
                'numeric or symbolic arrays');
    error(str);
  end
  if ~isequaldim(h, bb, hbp, sf, ab) && ...
    (~isscalar(h) && ~isscalar(bb) && ...
     ~isscalar(hbp) && ~isscalar(sf) && ~isscalar(ab))
    str = stack('input arguments must have', ...
                'the same array dimensions', ...
                'or be scalars');
    error(str);
  end
  %% on-base percentage formula
  percentage = (h+bb+hbp)./(bb+hbp+sf+ab);
  if convert2symfun
    percentage(args) = percentage;
  end
