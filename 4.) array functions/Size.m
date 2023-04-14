function varargout = Size(a, varargin)
  % ----------------------------------------------
  % - a slight variation of the size function
  % - for symbolic functions, will return
  %   the dimensions of its body
  % - since symbolic functions are always scalars, 
  %   the regular isempty function will always
  %   return [1 1] for symbolic functions
  % ----------------------------------------------
  narginchk(1,inf);
  ind = 1:max(nargout, 1);
  if issymfun(a)
    [varargout{ind}] = size(formula(a), varargin{:});
  else
    [varargout{ind}] = size(a, varargin{:});
  end
