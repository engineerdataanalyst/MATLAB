function varargout = randchar(dim, options)
  % ----------------------
  % - computes an array of
  %   random characters
  % ----------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    dim (1,:) double {mustBeNonempty, mustBeInteger, mustBePositive} = 1;
    options.Type ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Type, ["upper" "lower" "greek"])} = "upper";
  end
  % check the character type
  Type = lower(options.Type);
  %% compute the array of random characters
  switch Type
    case "upper"
      range = [65 90];
    case "lower"
      range = [97 122];
    case "greek"
      range = [913 969];
  end  
  for k = 1:max(nargout, 1)
    varargout{k} = char(randi(range, dim));
  end
