function para(varargin)
% ----------------------------------
% -returns the parabolic response
%  of a system of transfer functions
% ----------------------------------
  tfsize = arg.size({'tf', 'zpk'}, varargin{:});
  if tfsize == 0;
    error('there are no transfer functions to plot');
  end 
  t = 0:0.001:10';
  titlestr = 'Parabolic Response';
  legendlist = cell(0);
  argo = arg({'t', 'title', 'legend'},{t, titlestr, legendlist});
  [t titlestr legendlist] = argo.set(varargin{tfsize+1:nargin}); 
  lsim(varargin{1:tfsize}, 1/2*t.^2, t);
  title(titlestr);
  if ~isempty(legendlist)
    legend(legendlist);
  end 