function s = parse_rev_args(rev_args, options)
  % ------------------------------
  % - parses the input arguments
  %   of the revolution integerals  
  % ------------------------------
  
  %% check the input arguments
  arguments (Repeating)
    rev_args;
  end
  arguments
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["cartesian" ...
                                  "polar" ...
                                  "parametric"])} = "cartesian";
  end  
  %% parse the revolution integration arguments
  s.mode = lower(options.Mode);
  if ismember(s.mode, ["cartesian" "polar"])
    % check the number of integration input arguments
    if length(rev_args) < 2
      str = stack('for modes ''cartesian'' and ''polar'',', ...
                  'there should be at least 2', ...
                  'integration input arguments');
      error(str);
    end
    % compute y
    s.y = rev_args{1};
    if ~isnumeric(s.y) && ~issym(s.y)
      str = stack('for modes ''cartesian'' and ''polar'',', ...
                  '''y'' must be a numeric or symbolic array');
      error(str);
    end
    % compute x, range, A, and the integration options
    if issymvarscalar(rev_args{2})
      s.x = rev_args{2};
      if length(rev_args) >= 3
        s.range = rev_args{3};
        if (length(rev_args) >= 4) && ...
           ~isTextScalar(rev_args{4}, ["char" "string"]) && ...
           ~islogscalar(rev_args{4})
          s.A = rev_args{4};
          s.options = rev_args(5:end);
        else
          s.A = 0;
          s.options = rev_args(4:end);
        end
      else
        s.range = rev_args{2};
        if (length(rev_args) >= 3) && ...
           ~isTextScalar(rev_args{3}, ["char" "string"]) && ...
           ~islogscalar(rev_args{3})
          s.A = rev_args{3};
          s.options = rev_args(4:end);
        else
          s.A = 0;
          s.options = rev_args(3:end);
        end
      end
    else
      if isnumeric(s.y) || isallsymnum(s.y)
        s.x = sym('x');
      elseif issym(s.y)
        s.x = symvar(s.y, 1);
      else
        s.x = [];
      end
      s.range = rev_args{2};
      if (length(rev_args) >= 3) && ...
         ~isTextScalar(rev_args{3}, ["char" "string"]) && ...
         ~islogscalar(rev_args{3})
        s.A = rev_args{3};
        s.options = rev_args(4:end);
      else
        s.A = 0;
        s.options = rev_args(3:end);
      end
    end
    if ~issymvarscalar(s.x)
      str = stack('for modes ''cartesian'' and ''polar'',', ...
                  '''x'' must be a symbolic variable scalar');
      error(str);
    end
    % compute dy
    s.dy = diff(s.y, s.x);
  elseif s.mode == "parametric"
    % check the number of integration input arguments
    if length(rev_args) < 3
      str = stack('for mode ''parametric'',', ...
                  'there should be at least 3', ...
                  'integration input arguments');
      error(str);
    end
    % compute xt, yt
    s.xt = rev_args{1};
    s.yt = rev_args{2};
    if (~isnumeric(s.xt) && ~issym(s.xt)) || ...
       (~isnumeric(s.yt) && ~issym(s.yt))
      str = stack('for mode ''parametric'',', ...
                  '''xt'' and ''yt'' must be', ...
                  'numeric or symbolic expressions');
      error(str);
    end
    % compute t, range, A, and the integration options
    if issymvarscalar(rev_args{3})
      s.t = rev_args{3};
      if length(rev_args) >= 4
        s.range = rev_args{4};
      else
        s.range = [];
      end
      if (length(rev_args) >= 5) && ...
         ~isTextScalar(rev_args{5}, ["char" "string"]) && ...
         ~islogscalar(rev_args{5})
        s.A = rev_args{5};
        s.options = rev_args(6:end);
      else
        s.A = 0;
        s.options = rev_args(5:end);
      end
    else
      if isnumeric(s.xt) || isallsymnum(s.xt)
        s.t = sym('t');
      elseif issym(s.xt)
        s.t = symvar(s.xt, 1);
      else
        s.t = [];
      end
      s.range = rev_args{3};
      if (length(rev_args) >= 4) && ...
         ~isTextScalar(rev_args{4}, ["char" "string"]) && ...
         ~islogscalar(rev_args{4})
        s.A = rev_args{4};
        s.options = rev_args(5:end);
      else
        s.A = 0;
        s.options = rev_args(4:end);
      end
    end
    if ~issymvarscalar(s.t)
      str = stack('for mode ''parametric'',', ...
                  '''t'' parameter must be', ...
                  'a symbolic variable scalar');
      error(str);
    end
    % compute dxt and dyt
    s.dxt = diff(s.xt, s.t);
    s.dyt = diff(s.yt, s.t);
  end
  % check the range
  if ~isnumvector(s.range, 'Len', 2) && ~issymvector(s.range, 'Len', 2)
    str = stack('''range'' must be', ...
                'a numeric or symbolic', ...
                'vector of length 2');
    error(str);
  end
  % check the revolution axis
  if ~isnumeric(s.A) && ~issym(s.A)
    str = stack('revolution axis must be a', ...
                'numeric or symbolic arrray');
    error(str);
  end
