function s = parse_curvature_args(curvature_args, options)
  % ----------------------------
  % - parses the input arguments
  %   of the curvature function  
  % ----------------------------
  
  %% check the input arguments
  arguments (Repeating)
    curvature_args;
  end
  arguments
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["cartesian" ...
                                  "polar" ...
                                  "parametric"])} = "cartesian";
  end
  %% parse the curvature arguments
  s.mode = lower(options.Mode);
  if isempty(curvature_args)
    str = stack('there should be at least 1', ...
                'curvature input argument');
    error(str);
  end
  if ismember(s.mode, ["cartesian" "polar"])
    % compute y
    s.y = curvature_args{1};
    if ~isnumeric(s.y) && ~issym(s.y)
      str = stack('for modes ''cartesian'' and ''polar'',', ...
                  '''y'' must be a numeric or symbolic expression');
      error(str);
    end
    % compute x
    if length(curvature_args) == 2
      x = curvature_args{2};
    elseif isnumeric(s.y) || isallsymnum(s.y)
      x = sym('x');
    else
      x = symvar(s.y, 1);
    end
    if ~issymvarscalar(x)
      str = stack('for modes ''cartesian'' and ''polar'',', ...
                  '''x'' must be a symbolic variable scalar');
      error(str);
    end
    % compute dy and d2y
    s.dy = diff(s.y, x);
    s.d2y = diff(s.dy, x);
  elseif s.mode == "parametric"
    % compute S
    s.S = curvature_args{1};
    if iscell(s.S)
      numeric = cellfun(@isnumeric, s.S);
      symbolic = cellfun(@issym, s.S);
      allsymnum = cellfun(@isallsymnum, s.S);
      empty = cellfun(@isempty, s.S);
      valid_cell = all(numeric | symbolic, 'all') && ...
                  ~any(empty, 'all') && isvector(s.S) && ~isempty(s.S);
    else
      valid_cell = false;
    end
    if ~isnumvector(s.S) && ~issymvector(s.S) && ~valid_cell
      str = stack('for mode ''parametric'',', ...
                  '''S'' must be:', ...
                  '------------', ...
                  '1.) a numeric or symbolic vector', ...
                  '2.) a non-empty cell vector containing', ...
                  '    non-empty numeric or symbolic expressions');
      error(str);
    end
    % compute t
    if length(curvature_args) == 2
      t = curvature_args{2};
    elseif isnumeric(s.S) || isallsymnum(s.S) || ...
          (iscell(s.S) && all(numeric | allsymnum))
      t = sym('t');
    elseif iscell(s.S)
      t = symvar(s.S{1}, 1);
    else
      t = symvar(s.S, 1);
    end
    if ~issymvarscalar(t)
      str = stack('for mode ''parametric'',', ...
                  '''t'' must be a symbolic variable scalar');
      error(str);
    end
    % compute dS and dT
    if iscell(s.S)
      s.S = components2vector(s.S);
      t_cell = repmat({t}, size(s.S));
      s.dS = cellfun(@diff, s.S, t_cell, 'UniformOutput', false);
      s.dT = cellfun(@unit_vector, s.dS, 'UniformOutput', false);
      s.dT = cellfun(@diff, s.dT, t_cell, 'UniformOutput', false);
    else
      s.dS = diff(s.S, t);
      s.dT = diff(unit_vector(s.dS), t);
    end
  end
