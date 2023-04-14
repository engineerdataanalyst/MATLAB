function a = combine_logs(a, ind, options)
  % ---------------------
  % - combine the log
  %   expressions in a
  %   symbolic expression
  %   of log sums
  % ---------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.CommonExponents logical = true;
    options.FactorExponents logical = true;
  end
  % check the symbolic array
  if ~isScalar(a)
    error('''a'' must be a scalar');
  end
  % check the log index
  logs = findSymType(a, 'log');
  num_logs = length(logs);
  if ~isunique(ind)
    error('''ind'' must be unique');
  elseif ~all(ismember(ind, 1:num_logs)) && (num_logs ~= 0)
    str = stack('''ind'' must contain numbers', ...
                'that do not exceed', ...
                'the number of logs in ''a'' (%d)');
    error(str, num_logs);
  end
  % check the splitting flags
  CommonExponents = options.CommonExponents;
  FactorExponents = options.FactorExponents;
  [CommonExponents FactorExponents] = scalar_expand(CommonExponents, ...
                                                    FactorExponents, ind);
  if ~isvector(CommonExponents) || ~isvector(FactorExponents) || ...
     ~isequallen(CommonExponents, FactorExponents)
    str = stack('''CommonExponents'', and ''FactorExponents''', ...
                'must be vectors with compatible lengths');
    error(str);
  elseif length(CommonExponents) > length(ind)
    str = stack('the length of ''CommonExponents'' and', ...
                'the length of ''FactorExponents'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, length(CommonExponents), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(logs) || ~any(CommonExponents(:) | FactorExponents(:))
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% split the log arguments
  [sublist subvals] = deal(logs(ind));
  for k = 1:length(sublist)
    log_children = children(sublist(k), 1);
    [b n] = power_parts(log_children);
    if CommonExponents(k)
      F = factor(b);
      F_unique = unique(F, 'stable');
      [b log_n] = power_parts(F_unique);
      for p = 1:length(log_n)
        log_n(p) = log_n(p)*nnz(ismember(F, F_unique(p)));
      end
      n = n*log_n;
      if FactorExponents(k)
        subvals(k) = sum(n.*log(b));
      else
        subvals(k) = sum(log(b.^n));
      end
    elseif FactorExponents(k)
      subvals(k) = n*log(b);
    end
  end
  a = subs(a, sublist, subvals);
end
% =
function ind = default_ind(a)
  % ---------------------------------
  % - helper function for determining
  %   the default log index
  % ---------------------------------
  logs = findSymType(a, 'log');
  ind = 1:max(length(logs), 1);
end
% =
