function a = num2cellstr(a)
  % -----------------------------------------
  % - after calling num2cell on an array,
  %   calls num2str on each cell of the array
  % -----------------------------------------
  narginchk(1,1);
  a = cellfun(@num2str, num2cell(a), 'UniformOutput', false);
