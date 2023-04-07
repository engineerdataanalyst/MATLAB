function bool = isequaldim(varargin)
  % -------------------------------------
  % - returns true if all input arguments
  %   have the same dimensions
  % -------------------------------------
  narginchk(1,inf);
  if nargin == 1
    bool = true;
  else
    uniform = {'UniformOutput' false};    
    dims = cellfun(@Size, varargin, uniform{:});
    bool = isequal(dims{:});
  end
