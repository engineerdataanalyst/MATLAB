function str = scalar(a)
  % ----------------------------------
  % - returns the string 'invalid'
  %   if an array is not a text scalar
  % ----------------------------------
  narginchk(1,1);
  if isTextScalar(a, ["char" "string"])
    str = a;
  else
    str = 'invalid';
  end
