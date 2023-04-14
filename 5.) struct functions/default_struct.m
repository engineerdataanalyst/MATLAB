function s = default_struct(fields, options)
  % -------------------------------
  % - computes a structure array
  %   with a given set of fields
  %   that contain default values
  %  (empty arrays ([]) if no
  %   default values are specified)
  % -------------------------------
  
  %% check the input argument
  % check the argument classes
  arguments (Repeating)
    fields {mustBeTextScalar, mustBeNonzeroLengthText};
  end
  arguments
    options.Default;
  end
  % check the fields
  for k = find(startsWith(fields, '\'))
    fields{k}(1) = [];
  end
  % check the default values
  if ~isfield(options, 'Default')
    Default = {[]};
  elseif ~iscell(options.Default)
    Default = {options.Default};
  else
    Default = options.Default;
  end
  [~, Default] = scalar_expand(fields, Default);
  if ~isvector(Default)
    error('the default values must be a cell vector');
  elseif ~isequallen(fields, Default) && ~isempty(fields)
    str = stack('the number of default values must equal', ...
                'the number of fields of the struct');
    error(str);
  end
  %% compute the default structure array
  if isempty(fields)
    s = struct;
  else
    Args = [fields.' Default(:)].';
    s = struct(Args{:});
  end
