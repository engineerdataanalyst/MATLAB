function a = scale_logs(a, ind, options)
  % ---------------------
  % - scales the log
  %   arguments in a
  %   symbolic expression
  % ---------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.Scale sym = 1;
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
  % check scale factor
  Scale = scalar_expand(options.Scale, ind);
  if ~isVector(Scale)
    error('''Scale'' must be a vector');
  elseif Length(Scale) > length(ind)
    str = stack('the length of ''Scale'' (%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, Length(Scale), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(logs)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% scale the log arguments
  [sublist subvals] = deal(logs(ind));
  for k = 1:length(sublist)
    arg = index(Scale, k)*children(sublist(k), 1);
    subvals(k) = log(arg);
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
