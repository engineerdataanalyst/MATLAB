function varargout = ignore_args(s, varargin)
  ids = {'MATLAB:minlhs';
         'MATLAB:minrhs';
         'MATLAB:TooManyOutputs';
         'MATLAB:TooManyInputs';
         'MATLAB:nargoutchk:tooManyOutputs';
         'MATLAB:narginchk:tooManyInputs'};
  if ismember(s.identifier, ids)
    rethrow(s);
  end
  varargout = varargin;
