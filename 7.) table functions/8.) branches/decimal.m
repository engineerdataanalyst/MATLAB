function answer = decimal(z, options)
  % --------------------------------
  % - returns the following values
  %   based on the input argument z:
  % - 1: if z is a decimal
  %   0: if z is not a decimal
  % --------------------------------

  %% check the input argument
  arguments
    z {mustBeA(z, ["double" "sym"])};
    options.Logical (1,1) = false;
  end
  Logical = options.Logical;
  %% compute the decimal sign value
  Real = real(z);
  Imag = abs(imag(z));
  Mod = mod(Real.^(1-sign(Imag)), 1);
  answer = sign(Mod);
  if Logical && (isnumeric(answer) || isallsymnum(answer))
    answer = logical(answer);
  end
