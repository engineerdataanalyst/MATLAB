function answer = scalar_size(a)
  % -------------------------
  % - returns [1 1] if the
  %   input argument is empty
  % -------------------------
  narginchk(1,1);
  if isEmpty(a)
    answer = [1 1];
  else
    answer = Size(a);
  end
