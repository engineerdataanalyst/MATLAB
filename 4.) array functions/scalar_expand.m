function varargout = scalar_expand(varargin)
  % -----------------------------------------
  % - expands all scalar input arguments
  %   to the dimensions of the first
  %   non-scalar and non-empty input argument
  % -----------------------------------------
  
  %% check the input and output arguments
  narginchk(1,inf);
  if nargout > nargin
    str = stack('the number of output arguments', ...
                'must not exceed', ...
                'the number of input arguments');
    error(str);
  end
  %% scalar expand the input arguments
  func = @(arg) isTextScalar(arg, 'char');
  chars = cellfun(func, varargin);
  scalars = cellfun(@isScalar, varargin) | chars;
  emptys = cellfun(@isEmpty, varargin);
  if any(~scalars & ~emptys)
    uniform = {'UniformOutput' false};
    non_scalar_args = varargin(~scalars & ~emptys);
    func = @(arg) repmat(arg, Size(non_scalar_args{1}));
    varargin(chars) = cellfun(@cellstr, varargin(chars), uniform{:});
    varargin(scalars) = cellfun(func, varargin(scalars), uniform{:});
  end
  varargout = varargin(1:max(nargout, 1));
