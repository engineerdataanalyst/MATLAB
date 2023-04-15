function a = split_body(a, ind)
  % --------------------
  % - splits the body
  %   of an integral,
  %   symsum, or symprod
  %   expression
  % --------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
  end
  % check the symbolic array
  if ~isScalar(a)
    error('''a'' must be a scalar');
  end
  % check the expression index
  expr = findSymType(a, 'int | symsum | symprod');
  num_expr = length(expr);
  if ~isunique(ind)
    error('''ind'' must be unique');
  elseif ~all(ismember(ind, 1:num_expr)) && (num_expr ~= 0)
    str = stack('''ind'' must contain numbers', ...
                'that do not exceed', ...
                'the number of int, symsum, and symprod', ...
                'expressions in ''a'' (%d)');
    error(str, num_expr);
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% split the body of the symbolic expression
  [sublist subvals] = deal(expr(ind));
  for k = 1:length(sublist)
    % compute the children
    Children = children(sublist(k));
    if contains(string(sublist(k)), "'Hold'")
      Hold = {'Hold' true};
      Children(end-1:end) = [];
    elseif isSymType(sublist(k), 'int')
      Hold = {'Hold' false};
    else
      Hold = {};
    end
    % compute the integration/symsum parameters
    if length(Children) == 2
      [body var] = deal(Children{:});
      Args = Hold;
    else
      [body var lower_limit upper_limit] = deal(Children{:});
      Args = [{lower_limit upper_limit} Hold];
    end
    % split the body
    if ~ispiecewise(body) && isSymType(body, 'expression')
      body_children = sym(children(body));
      body_factors = factor(body);
      two_or_more_terms = isSymType(body, 'plus');
      if isSymType(sublist(k), 'int') && two_or_more_terms
        subvals(k) = sum(int(body_children, var, Args{:}));
      elseif isSymType(sublist(k), 'symsum') && two_or_more_terms
        subvals(k) = sum(symsum(body_children, var, Args{:}));
      elseif isSymType(sublist(k), 'symprod')
        subvals(k) = prod(symprod(body_factors, var, Args{:}));
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
  expr = findSymType(a, 'int | symsum | symprod');
  ind = 1:max(length(expr), 1);
end
% =
