function answer = integer(z, options)
  % --------------------------------
  % - returns the following values
  %   based on the input argument z:
  % - 1: if z is an integer
  %   0: if z is not an integer
  % --------------------------------

  %% check the input argument
  arguments
    z {mustBeA(z, ["double" "sym"])};
    options.Logical (1,1) = false;
  end
  Logical = options.Logical;
  %% compute the integer sign value
  Real = real(z);
  Imag = abs(imag(z));
  Mod = mod(Real, -1)-Imag;
  answer = heaviside(Mod);
  if Logical && (isnumeric(answer) || isallsymnum(answer))
    answer = logical(answer);
  end
