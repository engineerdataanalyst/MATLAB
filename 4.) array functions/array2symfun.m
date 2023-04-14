function anew = array2symfun(a, inputs)
  % ----------------------
  % - converts an array to
  %   a symbolic function
  % ----------------------
  narginchk(2,2);
  inputs = array2sym(inputs);
  anew(inputs) = array2sym(a);
