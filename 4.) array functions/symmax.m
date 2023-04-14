function [a_max ind_max] = symmax(a, error_str, options)
  % -------------------------------------------
  % - a slight variation of the max function
  % - will compute the maximum value 
  %   of any symbolic array numerically
  %   rather than how the original max function
  %   normally does
  % -------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    error_str;
  end
  arguments
    options.Dim ...
    {mustBeA(options.Dim, ["numeric" "char" "string"])} = default_dim(a);
  end
  % check the error string
  if isempty(error_str)
    error_str = {stack('unable to compute the maximum value(s)', ...
                       'of the symbolic array')};
  end
  for k = 1:length(error_str)
    if isTextScalar(error_str{k}, ["char" "string"]) && ...
       startsWith(error_str{k}, '\')
      error_str{k}(1) = [];
    end
  end
  % check the array dimension
  Dim = options.Dim;
  if isTextScalar(Dim, ["char" "string"])
    Dim = lower(Dim);
  end
  if (~isintscalar(Dim, 'Type', 'positive') || ...
      ~ismember(Dim, [1 2])) && ~isequal(Dim, 'all')
    error('''Dim'' must be 1, 2, or ''all''');
  end
  %% check for an empty array
  if isEmpty(a)
    [a_max ind_max] = max(a, [], Dim);
    return;
  end
  %% temporarily convert symbolic functions to sym arrays
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  %% make the following prerequisite checks
  % convert the array to a column vector if dim == 'all'
  if isequal(Dim, 'all')
    a = a(:);
  end
  % check for compatible units
  sort_vector = isequal(Dim, 'all') || ...
               (isrow(a) && Dim == 2) || (iscolumn(a) && Dim == 1);
  [scale coeff] = scalar_parts(a);
  compatible_units = checkUnits(sum(coeff(:)), 'Compatible');
  if ~compatible_units
    error('''a'' must have compatible units');
  end
  % check the scale factor
  scale_found = any(isAlways(scale == coeff(:), 'Unknown', 'false'));
  scale_found = scale_found && ~isallsymnum(scale);
  %% compute the maximum values of the symbolic array
  if sort_vector && isallsymnum(coeff) && ~scale_found
    % convert to consistent units
    [a_old units] = separateUnits(coeff);
    units = unique(units, 'stable');
    units(units == 0) = [];
    if isempty(units)
      units = sym(1);
    end
    if ~all(units(1) == units) && (units(1) ~= 1)
      coeff = rewrite(coeff, units(1));
      a_old = separateUnits(coeff);
    end
    % compute the maximum value of the symbolic vector
    if isAlwaysError(scale >= 0, error_str{:})
      [~, ind_max] = max(a_old);
    else
      [~, ind_max] = min(a_old);
    end
    a_max = a(ind_max);
  elseif sort_vector
    % general case for non-scalar multiple symbolic vectors
    ind_max = 1;
    for k = 2:length(a)
      if isAlwaysError(a(k) > a(ind_max), error_str{:})
        ind_max = k;
      end
    end
    a_max = a(ind_max);
  elseif (Dim == 1) && ismatrix(a)
    % compute the maximum value for each column
    % of the symbolic 2-D array
    num_cols = width(a);
    a_max = sym.zeros(1, num_cols);
    ind_max = zeros(1, num_cols);
    for k = 1:num_cols
      Args = {a(:,k) error_str};
      [a_max(k) ind_max(k)] = symmax(Args{:});
    end    
  elseif ismatrix(a)
    % compute the maximum value for each row
    % of the symbolic 2-D array
    num_rows = height(a);
    a_max = sym.zeros(num_rows, 1);
    ind_max = zeros(num_rows, 1);
    for k = 1:num_rows
      Args = {a(k,:) error_str};
      [a_max(k) ind_max(k)] = symmax(Args{:});
    end
  else
    % compute the maximum value for each 2-D array
    % of the symbolic array
    a_size = size(a);
    if Dim == 1
      a_max = sym.zeros([1 a_size(2:end)]);
      ind_max = zeros([1 a_size(2:end)]);
    else
      a_max = sym.zeros([a_size(1) 1 a_size(3:end)]);
      ind_max = zeros([a_size(1) 1 a_size(3:end)]);
    end
    for k = 1:prod(a_size(3:end))
      Args = {a(:,:,k) error_str 'Dim' Dim};
      [a_max(:,:,k) ind_max(:,:,k)] = symmax(Args{:});
    end
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    a_max(args) = a_max;
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the symbolic array
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
