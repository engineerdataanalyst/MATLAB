function a = Union(varargin)
  % ------------------------------------------
  % - a slight variation of the union function
  % - will union 2 or more arrays
  %   instead of just two arrays
  % ------------------------------------------
  a = fold(@union, varargin);
