function a = split_limits(a, ind, options)
  % -------------------------------
  % - splits the integration limits
  %   of a symbolic expression
  %   in either of these methods:
  % -------------
  % - method one:
  % -------------
  %   splits the limits
  %   as a difference of
  %   two integrals containing
  %   the limits
  % -------------
  % - method two:
  % -------------
  %   splits the limits at
  %   certain values
  %   in between the limits
  % -------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    ind (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBePositive} = default_ind(a);
    options.Mode (1,:) ...
    {mustBeText, ...
     mustBeMemberi(options.Mode, ["Difference" "Value"])} = "Value";
    options.Reference (1,:) = 0;
    options.Combine (1,:) logical = true;
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
  % check the Mode, Reference, and Combine flags
  Mode = lower(string(options.Mode));
  Reference = options.Reference;
  if isnumeric(Reference) || issym(Reference)
    Reference = {Reference};
  end
  if iscell(Reference)
    Reference = cellfun(@array2sym, Reference, 'UniformOutput', false);
    Reference = cellfun(@formula, Reference, 'UniformOutput', false);
    Reference = convert2row(Reference);
  else
    str = stack('''Reference'' must be:', ...
                '--------------------', ...
                '1.) numeric', ...
                '2.) symbolic', ...
                '3.) cell');
    error(str);
  end
  Combine = options.Combine;
  [Mode Reference Combine] = scalar_expand(Mode, Reference, Combine, ind);
  if ~isequallen(Mode, Reference, Combine) || ...
     ~all(cellfun(@isvector, Reference), 'all')
    str = stack('''Mode'', ''Reference'', and ''Combine''', ...
                'must be vectors with compatible lengths');
    error(str);
  elseif length(Mode) > length(ind)
    str = stack('the length of ''Mode'' and', ...
                'the length of ''Reference'' and', ...
                'the length of ''Combine''(%d)', ...
                'must not exceed', ...
                'the length of ''ind'' (%d)');
    error(str, length(Mode), length(ind));
  end
  %% temporarily clear the assumptions
  if isempty(expr)
    return;
  end
  old_assum = assumptions;
  cleanup = onCleanup(@() assume(old_assum));
  clearassum;
  %% split the integration limits
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
    % split the integration limits
    if length(Children) == 4
      [body var lower_limit upper_limit] = deal(Children{:});
      if Mode(k) == "difference"
        if ~isScalar(Reference{k})
          str = stack('''for mode ''Difference''', ...
                      '''Reference'' must be a scalar');
          error(str);
        end
        I = sym.zeros(2,1);
        I(1) = int(body, var, Reference{k}, upper_limit, Hold{:});
        I(2) = -int(body, var, Reference{k}, lower_limit, Hold{:});
      else
        Reference{k} = [lower_limit Reference{k} upper_limit];
        I = sym.zeros(size(Reference{k}));
        for p = 1:length(Reference{k})-1
          Args = [{body var Reference{k}(p) Reference{k}(p+1)} Hold];
          I(p) = int(Args{:});
        end
      end
      subvals(k) = sum(I);
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
