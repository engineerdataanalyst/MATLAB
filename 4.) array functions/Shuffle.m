function a = Shuffle(a, options)
  % -----------------------------------
  % - shuffles the contents of an array
  % -----------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a;
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
  end
  % check for symbolic functions
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end  
  % check the array dimension
  Dim = options.Dim;
  if ~ismember(Dim, [1 2])
    error('''Dim'' must be 1 or 2');
  end  
  %% shuffle the array
  if isempty(a)
    return;
  end
  shuffle_indices = randperm(size(a, Dim));
  if Dim == 1
    a = a(shuffle_indices,:);
  else
    a = a(:,shuffle_indices);
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    a(args) = a;
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the array
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
