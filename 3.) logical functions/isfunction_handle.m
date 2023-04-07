function bool = isfunction_handle(a)
  % ---------------------------
  % - returns true if an array
  %   is a function handle
  % ---------------------------
  narginchk(1,1);
  bool = isa(a, 'function_handle');
