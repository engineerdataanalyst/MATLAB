function a = reindex(a, ind, options)
  % -----------------------------------
  % - re-indexes a symsum or symprod
  %   expression to a new startng index
  % -----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.StartIndex sym = 1;
  end
  % check the symbolic array
  if ~isScalar(a)
    error('''a'' must be a scalar');
  end
  % check the expression index
  expr = findSymType(a, 'symsum | symprod');
  num_expr = length(expr);
  if ~isunique(ind)
    error('''ind'' must be unique');
  elseif ~all(ismember(ind, 1:num_expr)) && (num_expr ~= 0)
    str = stack('''ind'' must contain numbers', ...
                'that do not exceed', ...
                'the number of symsum and symprod', ...
                'expressions in ''a'' (%d)');
    error(str, num_expr);
  end
  % check the start index
  StartIndex = scalar_expand(options.StartIndex, ind);
  if ~isVector(StartIndex)
    error('''StartIndex'' must be a vector');
  elseif Length(StartIndex) > length(ind)
    str = stack('the length of ''StartIndex'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, Length(StartIndex), length(ind));
  elseif ~all(isAlways(isint(StartIndex), 'Unknown', 'true'))
    error('''StartIndex'' must contain integers');
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% re-index the summation/product array
  [sublist subvals] = deal(expr(ind));
  for k = 1:length(sublist)
    Children = children(sublist(k));
    if length(Children) == 4
      [body old_index lower_bound upper_bound] = deal(Children{:});
      start_index = index(StartIndex, k);
      lower_bound_diff = start_index-lower_bound;
      new_index = old_index-lower_bound_diff;
      body = subs(body, old_index, new_index);
      lower_bound = start_index;
      upper_bound = upper_bound+lower_bound_diff;
      if isSymType(sublist(k), 'symsum')
        subvals(k) = symsum(body, old_index, lower_bound, upper_bound);
      else
        subvals(k) = symprod(body, old_index, lower_bound, upper_bound);
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
  expr = findSymType(a, 'symsum | symprod');
  ind = 1:max(length(expr), 1);
end
% =
