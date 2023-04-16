function varargout = components2vector(a, options)
  % ----------------------------
  % - converts the components of
  %   the arrays in a cell array
  %   to a total vector
  % ----------------------------

  %% check the input arguments
  % check the argument classes
  arguments (Repeating)
    a {mustBeA(a, ["numeric" "sym"])};
  end
  arguments
    options.VectorType ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.VectorType, ["row" "col"])} = "row";
  end
  % check the argument dimensions
  if ~compatible_dims(a{:})
    error('input arguments must have compatible dimensions');
  end
  [a{:}] = scalar_expand(a{:});
  % check the for arguments that are not vectors
  if ~all(cellfun(@isVector, a))
    error('input arguments must be vectors');
  end
  % check for invalid arguments
  if ~isempty(a) && (nargout > length(a{1}))
    str = stack('the number of output arguments', ...
                'must not exceed', ...
                'the lengths of the cell array arguments');
    error(str);
  end
  % check the vector type
  VectorType = lower(string(options.VectorType));
  a = convert2row(a);
  %% convert the components to the total vector
  varargout = cell(0);
  for k = 1:max(nargout, 1)
    array = cell2array(a, k);
    array = [array{:}];
    varargout = [varargout; {array}];
  end
  if VectorType == "col"
    varargout = convert2col(varargout);
  end
