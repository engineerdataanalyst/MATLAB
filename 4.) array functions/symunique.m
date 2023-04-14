function [c inda indc] = symunique(a, options)
  % ---------------------------------------------
  % - a slight variation of the unique function
  % - will first convert all compatible units
  %   of a symbolic array to the same units,
  %   then will call the original unique function
  %   and the symsort function
  % ---------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["ascend" "descend"])} = "ascend";
  end
  % check the sorting mode
  Mode = lower(options.Mode)+" unique";
  %% compute the unique values of the symbolic array
  if nargout <= 1
    c = symsort(a, 'Mode', Mode);
  else
    [c inda] = symsort(a, 'Mode', Mode);    
  end  
  %% compute the unique indices for the unique array
  if nargout == 3
    a = formula(a);
    indc = zeros(size(a(:)));
    for k = 1:numel(a)
      if isnan(a(k))
        equal = isnan(c);
      else
        equal = isAlways(a(k) == c, 'Unknown', 'false');
      end
      indc(k) = find(equal, 1);
    end
    if isrow(c) && ~isscalar(indc)
      indc = indc.';
    end
  end
