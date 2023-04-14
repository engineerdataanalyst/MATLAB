function varargout = randsym(dim, options)
  % ---------------------------
  % - computes an array of
  %   random symbolic variables
  % ---------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    dim (1,:) double {mustBeNonempty, mustBeInteger, mustBePositive} = 1;
    options.Vars2Exclude sym = sym.empty(1, 0);
    options.Defaults sym = sym.empty(1, 0);
  end
  % check the variables to exclude
  Vars2Exclude = options.Vars2Exclude;
  if ~issymvarvector(Vars2Exclude) && ~isEmpty(Vars2Exclude)
    str = stack('''Vars2Exclude'' must be:', ...
                '-----------------------', ...
                '1.) a symbolic vector of variables', ...
                '2.) an empty array');
    error(str);
  elseif ~isVector(Vars2Exclude)
    Vars2Exclude = reshape(Vars2Exclude, 1, 0);
  end
  % check the default variables
  Defaults = formula(options.Defaults);
  if isscalar(Defaults) && (prod(dim) ~= 1)
    Defaults = repmat(Defaults, dim);
  end
  if ~isallsymvar(Defaults) && ~isempty(Defaults)
    str = stack('''Defaults'' must be:', ...
                '-------------------', ...
                '1.) a symbolic array of variables', ...
                '2.) an empty array');
    error(str);
  end  
  if ~isdim(Defaults, dim) && ~isempty(Defaults)
    str = stack('''Defaults'' must have dimensions', ...
                'that are specified by ''dim''');
    error(str);
  end
  %% compute the array of random symbolic variables
  if ~isEmpty(Defaults)
    Defaults_loc = ismember(Defaults, formula(Vars2Exclude));
  else
    Defaults_loc = true(dim);
  end
  for k = 1:max(max(nargout, 1)-1, 1)
    varargout{k} = sym.zeros(dim);
    if ~isEmpty(Defaults)
      varargout{k}(~Defaults_loc) = Defaults(~Defaults_loc);
    end
    for p = find(Defaults_loc(:)).'
      % compute the random symbolic variable
      str = string(randchar('Type', 'lower'));
      var_found = true;
      while var_found
        str = str+randi([0 9]);
        var_found = ismember(str, Vars2Exclude);
      end
      varargout{k}(p) = sym(str);
      % update the variables to exclude
      if isRow(Vars2Exclude)
        Vars2Exclude = [Vars2Exclude varargout{k}(p)];
      else
        Vars2Exclude = [Vars2Exclude; varargout{k}(p)];
      end
    end
  end
  %% assign the variables to exclude to the output arguments
  if nargout > 1
    varargout{end+1} = Vars2Exclude;
  end
