function a = split_logs(a, ind, options)
  % ---------------------
  % - splits the log
  %   arguments in a
  %   symbolic expression
  % ---------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.SplitFactors logical = true;
    options.FactorExponents logical = true;
    options.FactorMode ...
    {mustBeNonzeroLengthText, ...
     mustBeMemberi(options.FactorMode, ["children" ...
                                        "factor"])} = "children";
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
  SplitFactors = options.SplitFactors;
  FactorExponents = options.FactorExponents;
  FactorMode = lower(string(options.FactorMode));
  [SplitFactors ...
   FactorExponents FactorMode] = scalar_expand(SplitFactors, ...
                                               FactorExponents, ...
                                               FactorMode, ind);
  if ~isvector(SplitFactors) || ...
     ~isvector(FactorExponents) || ~isvector(FactorMode) || ...
     ~isequallen(SplitFactors, FactorExponents, FactorMode)
    str = stack(['''SplitFactors'', ' ...
                 '''FactorExponents'', and ''FactorMode'''], ...
                'must be vectors with compatible lengths');
    error(str);
  elseif any([length(SplitFactors) length(FactorMode)] > length(ind))
    str = stack('the length of ''SplitFactors'',', ...
                'the length of ''FactorExponents'', and', ...
                'the length of ''FactorMode'' (%d)''', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, length(SplitFactors), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(logs) || ~any(SplitFactors(:) | FactorExponents(:))
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
    if SplitFactors(k)
      F = sym(feval(FactorMode(k), b));
      if (FactorMode(k) == "children") && ~isequal(prod(F), b)
        F = b;
      end
      [b log_n] = power_parts(F);
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
