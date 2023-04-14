function varargout = symrandis(varargin)
  % ---------------------------
  % - a slight variation of
  %   the randi function
  % - will return a variable
  %   output of random integers
  %   computed by randi
  %   in symbolic form
  % ---------------------------
  for k = 1:max(nargout, 1)
    varargout{k} = sym(randi(varargin{:}));
  end
