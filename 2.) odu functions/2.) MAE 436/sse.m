function sse(input, varargin)
% ----------------------------------
% -returns the steady state error plot
%  of system of transfer functions
%  responding to a given input
% ----------------------------------
% -input arguments:
% =input: a string indicating the input function
%        ('step', 'ramp', or 'para')
% =transfer functions list
% =optional argument list:
%  1.) 't':      range of t to plot
%  2.) 'title':  title for the plot
%  3.) 'legend': a legend for the plot  
% ---------------------------------- 
  vararglen = length(varargin);
  tfsize = arg.size({'tf', 'zpk'}, varargin{:});    
%   for k = 1:vararglen    
%     if ~strcmp(class(varargin{k}), 'tf')
%       break;      
%     end
%     tfsize = tfsize+1;
%   end
  if tfsize == 0;
    error('there are no transfer functions to plot');
  end
  t = 0:0.001:10';  
  titlestr = {'Error Plot', [['(' input] ' input)']};
  legendvals = cell(0); 
  argo = arg({'t', 'title', 'legend'},{t, titlestr, legendvals});
  [t titlestr legendvals] = argo.set(varargin{tfsize+1:vararglen});
  switch input
    case 'step'
      r = t.^0;
    case 'ramp'
      r = t;
    case 'para'
      r = 1/2*t.^2;
      input = [input 'bolic'];
    otherwise
      error('input must be "step", "ramp", or "para"');
  end 
  xyvals = cell(2*tfsize);  
  for k = 1:2:2*tfsize
    xyvals(k) = {t};
    xyvals(k+1) = {r-lsim(varargin{(k+1)/2},r,t)'};    
  end
  plot(xyvals{:});  
  title(titlestr);
  xlabel('Time (seconds)');
  ylabel('Steady State Error');
  if ~isempty(legendvals)
    legend(legendvals);
  end 