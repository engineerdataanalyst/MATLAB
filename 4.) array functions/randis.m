function varargout = randis(varargin)
  % ---------------------------
  % - a slight variation of
  %   the randi function
  % - will return a variable
  %   output of random integers
  %   computed by randi
  % ---------------------------
  for k = 1:max(nargout, 1)
    varargout{k} = randi(varargin{:});
  end
