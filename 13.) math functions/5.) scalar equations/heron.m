function [a b c area num_tries] = heron(max)
  % ----------------------------------
  % - computes a random Heron Triangle
  %   with sides a, b, and c.
  % ----------------------------------
  
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
  %% compute the Heron Triangle
  area = 0;
  num_tries = 0;
  while ~isint(area, 'positive')
    a = randi(max);
    b = randi(max);
    c = randi(max);
    s = (a+b+c)/2;
    area = sqrt(s*(s-a)*(s-b)*(s-c));
    num_tries = num_tries+1;    
  end
