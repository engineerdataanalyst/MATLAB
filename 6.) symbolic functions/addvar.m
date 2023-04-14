function addvar(a, options)
  % ----------------------------------
  % - adds the symbolic variables of a
  %   symbolic array to the workspace
  % ----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    a {mustBeA(a, "sym")};
  end
  arguments
    options.Workspace ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Workspace, ["base" "caller"])} = "caller";
    options.Overwrite (1,1) logical = false;
  end
  % check the workspace
  Workspace = lower(options.Workspace);
  % check the overwrite flag
  Overwrite = options.Overwrite;
  % check the symbolic arrays
  if isempty(a)
    str = stack('there must be at least 1 symbolic array', ...
                'passed as an input argument');
    error(str);
  end
  %% compute the symbolic variables to add
  a_vars = sym(cellfun(@symvar, a, 'UniformOutput', false));
  a_vars = unique(a_vars);
  a_varnames = arrayfun(@char, a_vars, 'UniformOutput', false);
  %% compute the workspace variables
  s = evalin(Workspace, 'builtin(''whos'')');
  fields = setdiff(fieldnames(s), 'name');
  t = struct2table(rmfield(s, fields));
  workspace_varnames = t.name;
  %% add the symbolic variables to the workspace
  if Overwrite
    loc = true(size(a_vars));
  else
    loc = ~ismember(a_vars, workspace_varnames);
  end
  for k = find(loc)
    assignin(Workspace, a_varnames{k}, a_vars(k));
  end
