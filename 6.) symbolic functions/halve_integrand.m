function a = halve_integrand(a, ind, options)
  % --------------------------------
  % - halves the integrand
  %   of an even symbolic expression
  %   and adjusts the limits
  %   of integration accordingly
  % --------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.Combine logical = true;
  end
  % check the symbolic array
  if ~isScalar(a)
    error('''a'' must be a scalar');
  end
  % check the expression index
  expr = findSymType(a, 'int');
  num_expr = length(expr);
  if ~isunique(ind)
    error('''ind'' must be unique');
  elseif ~all(ismember(ind, 1:num_expr)) && (num_expr ~= 0)
    str = stack('''ind'' must contain numbers', ...
                'that do not exceed', ...
                'the number of int', ...
                'expressions in ''a'' (%d)');
    error(str, num_expr);
  end
  % check the combine flag
  Combine = scalar_expand(options.Combine, ind);
  [~, Combine] = scalar_expand(a, Combine);
  if ~isVector(Combine)
    error('''Combine'' must be a vector');
  elseif Length(Combine) > length(ind)
    str = stack('the length of ''Combine'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, Length(Combine), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  even = @(body, var, lower_limit, upper_limit) ...
         isevenfun(body) && ...
         isAlways(lower_limit == 0, 'Unknown', 'false') || ...
         isAlways(upper_limit == 0, 'Unknown', 'false');
  %% double the integrand of the symbolic expression
  [sublist subvals] = deal(expr(ind));
  for k = 1:length(sublist)
    % compute the children
    Children = children(sublist(k));
    if contains(string(sublist(k)), "'Hold'")
      Hold = {'Hold' true};
      Children(end-1:end) = [];
    else
      Hold = {'Hold' false};
    end
    % compute the integration parameters
    if length(Children) == 2
      [body var] = deal(Children{:});
      [lower_limit upper_limit] = deal(nan);
    else
      [body var lower_limit upper_limit] = deal(Children{:});
    end
    % double the integrand
    if even(body, var, lower_limit, upper_limit)
      if isAlways(lower_limit == 0, 'Unknown', 'false')
        subvals(k) = int(body, var, -upper_limit, upper_limit, Hold{:})/2;
      elseif isAlways(upper_limit == 0, 'Unknown', 'false')
        subvals(k) = int(body, var, lower_limit, -lower_limit, Hold{:})/2;
      end
      if Combine(k)
        subvals(k) = combine(subvals(k), 'int');
      end
    end
  end
  a = subs(a, sublist, subvals);
end
% =
function ind = default_ind(a)
  % ---------------------------------
  % - helper function for determining
  %   the default expression index
  % ---------------------------------
  expr = findSymType(a, 'int');
  ind = 1:max(length(expr), 1);
end
% =
