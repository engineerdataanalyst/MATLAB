function varargout = symrands(varargin)
  % --------------------------
  % - a slight variation of
  %   the rand function
  % - will return a variable
  %   output of random numbers
  %   computed by rand
  %   in symbolic form
  % --------------------------
  for k = 1:max(nargout, 1)
    varargout{k} = sym(rand(varargin{:}));
  end
