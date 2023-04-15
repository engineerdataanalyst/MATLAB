function percentage = slg(singles, doubles, triples, hr, ab)
  % -----------------------------
  % - slugging percentage formula
  %   used in MLB
  % -----------------------------

  %% convert symbolic function arguments to sym
  args = {};
  if issymfun(singles)
    args(end+1) = {argnames(singles)};
    singles = formula(singles);
  end
  if issymfun(doubles)
    args(end+1) = {argnames(doubles)};
    doubles = formula(doubles);
  end
  if issymfun(triples)
    args(end+1) = {argnames(triples)};
    triples = formula(triples);
  end
  if issymfun(hr)
    args(end+1) = {argnames(hr)};
    hr = formula(hr);
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
  if (~isnumeric(singles) && ~issym(singles)) || ...
     (~isnumeric(doubles) && ~issym(doubles)) || ...
     (~isnumeric(triples) && ~issym(triples)) || ...
     (~isnumeric(hr) && ~issym(hr)) || ...
     (~isnumeric(ab) && ~issym(ab))
    str = stack('input arguments must be', ...
                'numeric or symbolic arrays');
    error(str);
  end
  if ~isequaldim(singles, doubles, triples, hr, ab) && ...
    (~isscalar(singles) && ~isscalar(doubles) && ...
     ~isscalar(triples) && ~isscalar(hr) && ~isscalar(ab))
    str = stack('input arguments must have', ...
                'the same array dimensions', ...
                'or be scalars');
    error(str);
  end
  %% slugging percentage formula
  percentage = (singles+2*doubles+3*triples+4*hr)./ab;
  if convert2symfun
    percentage(args) = percentage;
  end
