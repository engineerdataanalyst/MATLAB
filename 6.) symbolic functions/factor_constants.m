function a = factor_constants(a, ind)
  % -----------------------
  % - factors out constants
  %   from an integral,
  %   symsum, or symprod
  %   expression
  % -----------------------
  
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
      [lower_limit upper_limit] = deal(0);
      Args = Hold;
    else
      [body var lower_limit upper_limit] = deal(Children{:});
      Args = [{lower_limit upper_limit} Hold];
    end
    % factor out the constants
    if ~ispiecewise(body)
      body_factors = factor(body);
      body_vars = arrayfun(@symvar, body_factors, 'UniformOutput', false);
      func = @(arg) ~ismember(var, arg);
      constants = cellfun(func, body_vars);
      C = prod(body_factors(constants));
      A = prod(body_factors(~constants));
      N = upper_limit-lower_limit+1;
      if isSymType(sublist(k), 'int')
        subvals(k) = C*int(A, var, Args{:});
      elseif isSymType(sublist(k), 'symsum')
        subvals(k) = C*symsum(A, var, Args{:});
      elseif isfinite(lower_limit) && isfinite(upper_limit)
        subvals(k) = C^N*symprod(A, var, Args{:});
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
