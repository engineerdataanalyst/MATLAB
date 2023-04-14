function a = change_index(a, ind, options)
  % -------------------------------------
  % - changes the summation/product index
  %   of a symsum/symprod expression
  % -------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.NewIndex sym = default_NewIndex(a);
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
  NewIndex = scalar_expand(options.NewIndex, ind);
  if ~isVector(NewIndex)
    error('''NewIndex'' must be a vector');
  elseif Length(NewIndex) > length(ind)
    str = stack('the length of ''NewIndex'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, Length(NewIndex), length(ind));
  elseif any(ismember(symvar(NewIndex), symvar(a)))
    str = stack('''NewIndex'' must not contain', ...
                'the variables of ''a''');
    error(str);
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% change the summation/product index
  [sublist subvals] = deal(expr(ind));
  for k = 1:length(sublist)
    % compute the summation/product parameters
    Children = children(sublist(k));
    if length(Children) == 2
      [body old_index] = deal(Children{:});
      bound_args = {};
    else
      [body old_index lower_bound upper_bound] = deal(Children{:});
      bound_args = {lower_bound upper_bound};
    end
    new_index = index(NewIndex, k);
    % change the summation/product index
    body = subs(body, old_index, new_index);
    if isSymType(sublist(k), 'symsum')
      subvals(k) = symsum(body, new_index, bound_args{:});
    else
      subvals(k) = symprod(body, new_index, bound_args{:});
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
function NewIndex = default_NewIndex(a)
  % ---------------------------------
  % - helper function for determining
  %   the default NewIndex value
  % ---------------------------------
  func = @(arg) children(arg, 2);
  expr = findSymType(a, 'symsum | symprod');
  NewIndex = arrayfun(func, expr);
end
% =
