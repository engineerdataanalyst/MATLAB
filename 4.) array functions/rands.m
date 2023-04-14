function varargout = rands(varargin)
  % --------------------------
  % - a slight variation of
  %   the rand function
  % - will return a variable
  %   output of random numbers
  %   computed by rand
  % --------------------------
  for k = 1:max(nargout, 1)
    varargout{k} = rand(varargin{:});
  end
