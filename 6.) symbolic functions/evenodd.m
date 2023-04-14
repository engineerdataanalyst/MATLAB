function [even odd] = evenodd(a, x)
  % --------------------------
  % - decomposes an array into
  %   even and odd functions
  % --------------------------
  
  %% check the input argument
  % check the argument classes
  arguments
    a sym;
    x sym = default_var(a);
  end
  % check the argument dimensions
  if ~compatible_dims(a, x)
    error('input arguments must have compatible dimensions');
  end
  [~, x] = scalar_expand(a, x);
  % check the array
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  % check the symbolic variables
  if ~isallsymvar(x)
    error('''x'' must be an array of symbolic variables');
  elseif issymfun(x)
    x = formula(x);
  end
  %% compute the even and odd functions
  [even odd] = deal(sym.zeros(size(a)));
  for k = 1:numel(a)
    a_neg = subs(a(k), x(k), -x(k));
    even(k) = (a(k)+a_neg)/2;
    odd(k) = (a(k)-a_neg)/2;
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    even(args) = even;
    odd(args) = odd;
  end
end
% =
function x = default_var(a)
  % ---------------------------------
  % - helper function for determining
  %   the default symbolic variable
  % ---------------------------------
  if issym(a) && ~isallsymnum(a)
    x = symvar(a, 1);
  else
    x = sym('x');
  end
end
% =
