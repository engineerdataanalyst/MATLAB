function rmvar(a, options)
  % -------------------------------------
  % - removes the symbolic variables of a
  %   symbolic array from the workspace
  % -------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    a {mustBeA(a, "sym")};
  end
  arguments
    options.Workspace ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Workspace, ["base" "caller"])} = "caller";
  end
  % check the workspace
  Workspace = lower(options.Workspace);
  % check the symbolic arrays
  if isempty(a)
    str = stack('there must be at least 1 symbolic array', ...
                'passed as an input argument');
    error(str);
  end
  %% compute the symbolic variables to remove
  a_vars = sym(cellfun(@symvar, a, 'UniformOutput', false));
  a_vars = unique(a_vars);
  a_varnames = arrayfun(@char, a_vars, 'UniformOutput', false);
  %% compute the workspace variables
  s = evalin(Workspace, 'builtin(''whos'')');
  fields = setdiff(fieldnames(s), 'name');
  t = struct2table(rmfield(s, fields));
  if isempty(t)
    return;
  end
  workspace_varnames = t.name;
  workspace_vars = ['{' repmat('%s ', size(workspace_varnames.')) '}'];
  workspace_vars = sprintf(workspace_vars, workspace_varnames{:});
  workspace_vars = evalin(Workspace, workspace_vars).';
  %% remove the symbolic variables from the workspace
  func = @(arg) issymvarscalar(arg) && ~issymfun(arg);
  loc = ismember(workspace_varnames, a_varnames) & ...
        cellfun(func, workspace_vars);
  for k = find(loc).'
    str = sprintf('builtin(''clear'', ''%s'')', workspace_varnames{k});
    evalin(Workspace, str);
  end
