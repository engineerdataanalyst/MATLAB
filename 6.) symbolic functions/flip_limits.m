function a = flip_limits(a, ind, options)
  % ------------------------------
  % - flips the integration limits
  %   of a symbolic expression
  %   and adjusts the
  %   integral accordingly
  % ------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.Combine (1,:) logical = true;
    options.Even (1,:) logical = false;
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
  % check the combine and even flags
  Combine = options.Combine;
  Even = options.Even;
  [Combine Even] = scalar_expand(Combine, Even, ind);
  if ~isequallen(Combine, Even)
    str = stack('''Combine'', and ''Even''', ...
                'must be vectors with compatible lengths');
    error(str);
  elseif length(Combine) > length(ind)
    str = stack('the length of ''Combine'' and', ...
                'the length of ''Even'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, length(Combine), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  even = @(body, var, lower_limit, upper_limit) ...
         isevenfun(body, var) && ...
        (isAlways(lower_limit == 0, 'Unknown', 'false') || ...
         isAlways(upper_limit == 0, 'Unknown', 'false'));
  %% flip the integration limits
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
    % flip the integration limits
    if length(Children) == 4
      [body var lower_limit upper_limit] = deal(Children{:});
      if ~Even(k)
        subvals(k) = -int(body, var, upper_limit, lower_limit, Hold{:});
        if Combine(k)
          subvals(k) = combine(subvals(k), 'int');
        end
      elseif even(body, var, lower_limit, upper_limit)
        subvals(k) = int(body, var, -upper_limit, -lower_limit, Hold{:});
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
