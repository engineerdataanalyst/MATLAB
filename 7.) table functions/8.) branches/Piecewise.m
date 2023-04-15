function a = Piecewise(varargin)
  % ----------------------------
  % - a slight varation of
  %   the piecewise functtion
  % - will compute a non-scalar
  %   piecewise expression
  %   based on the sizes
  %   of the piecewise arguments
  % ----------------------------
  
  %% check the input argument
  % check the argument classes
  arguments (Repeating)
    varargin sym;
  end
  % check the argument dimensions
  narginchk(2,inf);
  if ~compatible_dims(varargin{:})
    error('input arguments must have compatible dimensions');
  end
  % check for valid symbolic functions
  uniform = {'UniformOutput' false};
  symfuns = cellfun(@issymfun, varargin);
  args = cellfun(@argnames, varargin(symfuns), uniform{:});
  if ~isallequal(args)
    error(message('symbolic:symfun:InputMatch'));
  elseif ~isempty(args)
    args = args{1};
  end
  %% compute the non-scalar piecewise expression
  [varargin{:}] = scalar_expand(varargin{:});
  emptys = cellfun(@isEmpty, varargin);
  if any(~emptys)
    non_empty_arg = varargin(~emptys);
    non_empty_arg = non_empty_arg{1};
  else
    non_empty_arg = varargin{1};
  end
  a = sym.zeros(size(non_empty_arg));
  for k = 1:numel(non_empty_arg)
    pw_args = varargin;
    pw_args(~emptys) = cell2array(varargin(~emptys), k);
    a(k) = piecewise(pw_args{:});
  end
  %% convert to symbolic function if possible
  if ~isempty(args)
    a(args) = a;
  end
