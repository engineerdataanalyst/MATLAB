function bool = isequallen(varargin)
  % -------------------------------------
  % - returns true if all input arguments
  %   have the same length
  % -------------------------------------
  narginchk(1,inf);
  if nargin == 1
    bool = true;
  else
    uniform = {'UniformOutput' false};    
    lens = cellfun(@Length, varargin, uniform{:});
    bool = isequal(lens{:});
  end
