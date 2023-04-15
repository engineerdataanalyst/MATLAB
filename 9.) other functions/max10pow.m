function tenPow = max10pow(num)
  % ---------------------
  % - returns the maximum
  %   power of ten for an
  %   array of numbers
  % ---------------------
  
  %% check the input argument
  % check the argument class
  arguments
    num {mustBeA(num, ["numeric" "sym"])};
  end
  % check the array of numbers
  if issym(num) && ~isallsymnum(num)
    error('symbolic input arguemtns must be numbers');
  end
  %% compute the maximum power of ten
  num = abs(num);
  tenPow = zeros(size(num), 'like', num);
  for k = find(num(:) >= 10).'
    tenPow(k) = 1;
    while num(k)/10^tenPow(k) >= 10
      tenPow(k) = tenPow(k)+1;
    end
  end
