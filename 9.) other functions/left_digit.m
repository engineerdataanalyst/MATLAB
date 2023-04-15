function digit = left_digit(num)
  % ------------------------
  % - returns the left digit
  %   of an array of numbers
  % ------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    num {mustBeA(num, ["numeric" "sym"])};
  end
  % check the array of numbers
  if issym(num) && ~isallsymnum(num)
    error('symbolic input arguemtns must be numbers');
  end
  %% compute the left digit
  num = floor(abs(num));  
  digit = floor(num./10.^max10pow(num));
