function [a b c area num_tries] = pythagorean(max)
  % -------------------------------
  % - computes a random Pythagorean
  %   Triple Triangle with legs
  %   a, b and hypotenuse c.
  % -------------------------------
  
  %% compute the default input arguments
  if nargin == 0
    max = 20;    
  end  
  %% check the input arguments  
  if ~isintscalar(max) || max < 5
    str = stack('input argument must be', ...
                'an integer greater than or equal to 5');
    error(str);
  end
  %% compute the Pythagorian Triple Triangle
  a = 0;
  b = 0;
  c = 2;
  area = 0;
  num_tries = 0;
  while a^2+b^2 ~= c^2
    a = randi(max);
    b = randi(max);
    c = randi(max);
    area = 1/2*a*b;
    num_tries = num_tries+1;    
  end
