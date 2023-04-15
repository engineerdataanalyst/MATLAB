function a = intsubs(a, old, new)
  % ----------------------------
  % - modifies the subs function
  %   for integrals with holds
  %   so that it will do the
  %   substitution correctly
  % ----------------------------
  
  %% check the input arguments
  % check the argument class
  arguments
    a sym;
    old sym;
    new sym;
  end
  % check the argument dimensions
  if ~isequaldim(old, new)
    error('''old'' and ''new'' must have the same dimensions');
  end
  %% do the integral substitutions
  a = mapSymType(a, 'int', @(a) subsfun(a, old, new));
end
% =
function a = subsfun(a, old, new)
  % ----------------------------
  % - helper function for doing
  %   the integral substitutions
  % ----------------------------
  
  %% temporarily clear the assumptions
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  fun = @(arg) subs(arg, old, new);
  %% compute the children
  Children = children(a);
  if contains(string(a), "'Hold'")
    Hold = {'Hold' true};
    Children(end-1:end) = [];
  else
    Hold = {'Hold' false};
  end
  Children = cellfun(fun, Children, 'UniformOutput', false);
  %% compute the integration parameters
  if length(Children) == 2
    [body var] = deal(Children{:});
    limit_args = Hold;
  else
    [body var lower_limit upper_limit] = deal(Children{:});
    limit_args = [{lower_limit upper_limit} Hold];
  end
  %% do the integral substitutions
  a = int(body, var, limit_args{:});
end
% =
