function clearassum(varargin)
  % --------------------------------
  % - clears the assumptions
  %   on a set of symbolic variables
  % --------------------------------
  
  %% check the input arguments
  symvarscalars = cellfun(@issymvarscalar, varargin);
  if ~all(symvarscalars)
    error('input arguments must be symbolic variable scalars');
  end
  %% clear the assumptions
  if nargin == 0
    vars = symvar(assumptions);
  else
    vars = sym(varargin);
  end
  assume(vars, 'clear');
