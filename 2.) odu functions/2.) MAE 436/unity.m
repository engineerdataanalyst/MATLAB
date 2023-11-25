function [G T] = unity(num, den, varargin)
% -returns the G(s) and T(s) transfer functions
% corresponding to the unity feedback loop
% -input arguments:
% num: numerator coefficients of the open loop transfer function
% den: denominator coefficients of the open loop transfer function
% -output arguments:
% G(s): open loop transfer function
% T(s): closed loop transfer function.
switch nargin
  case 2
    G = minreal(tf(num, den));
  case 3
    G = minreal(zpk(num, den, varargin{:}));
  otherwise
    error('number of arguments must be 2 (tf) or 3 (zpk)');
end
T = feedback(G,1);