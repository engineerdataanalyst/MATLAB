function a = Namedargs2cell(a)
  % ---------------------------------------------------
  % - a slight variation of the namedargs2cell function
  % - will convert a scalar structure containing
  %   non-scalar name-value pair arguments
  %   into a compatible cell array format
  % ---------------------------------------------------

  %% check the input arguments
  arguments
    a (1,1) {mustBeA(a, "struct")};
  end
  %% convert the name value pair structure array
  a = namedargs2cell(a);
  if ~isempty(a)
    [a{:}] = scalar_expand(a{:});
    a(1:2:end) = cellfun(@string, a(1:2:end), 'UniformOutput', false);
  end
