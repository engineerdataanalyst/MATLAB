function answer = SignIm(z, options)
  % -------------------------------------------
  % - a slight variation of the signIm function
  % - will return the following values
  %   based on the input argument z:
  %    1: if z is a positive real number
  %       or a complex number if specified
  %    0: if z == 0
  %       or a complex number if specified
  %   -1: if z is a negative real number
  %       or a complex number if specified
  % -------------------------------------------

  %% check the input arguments
  % check the argument classes
  arguments
    z {mustBeA(z, ["double" "sym"])};
    options.ComplexSign ...
    {mustBeNonzeroLengthText, ...
     mustBeMemberi(options.ComplexSign,...
                   ["positive" "zero" "negative"])} = "positive";
  end
  % check the argument dimension
  ComplexSign = lower(string(options.ComplexSign));
  [z ComplexSign] = scalar_expand(z, ComplexSign);
  if ~compatible_dims(z, ComplexSign)
    error('input arguments must have compatible dimensions');
  end
  %% compute the signIm variables
  Real = real(-z);
  Imag = abs(imag(z));
  Sign = cell(2,1);
  Sign{1} = ones(Size(z), 'like', z);
  Sign{2} = Sign{1};
  if issymfun(z)
    Sign = cellfun(@formula, Sign, 'UniformOuput', false);
  end
  %% compute the modified signIm function
  negative = ComplexSign == "negative";
  zero = ComplexSign == "zero";
  Sign{1}(negative) = -1;
  Sign{2}(zero) = 1-sign(index(Imag, zero));
  answer = signIm((Real+Imag*1i.*Sign{1}).*Sign{2});
