function a = array2cellsymstr(a)
  % ---------------------------------------
  % - converts an array to a
  %   cell array symbolic character vectors
  % ---------------------------------------
  narginchk(1,1);
  a = cellfun(@char, array2cellsym(a), 'UniformOutput', false);
