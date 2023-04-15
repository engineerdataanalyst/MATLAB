function setassum(assum, error_str, options)
  % -------------------------------------
  % - a slight variation of the 
  %   assume and assumeAlso functions
  % - will set an array of assumptions
  %   and throw an error containing
  %   the input string and display
  %   a cause error thrown by the assumes
  % -------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    assum sym;
  end
  arguments (Repeating)
    error_str;
  end
  arguments
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["standard" ...
                                  "append" ...
                                  "clear"])} = "standard";
  end
  % check the error string
  if isempty(error_str)
    error_str = {'unable to set the symbolic assumption(s)'};
  end
  for k = 1:length(error_str)
    if isTextScalar(error_str{k}, ["char" "string"]) && ...
       matches(error_str{k}, "\Mode", 'IgnoreCase', true)
      error_str{k}(1) = [];
    end
  end
  % check the assumption mode
  Mode = lower(options.Mode);
  %% set the symbolic assumptions
  try
    if Mode == "clear"
      clearassum;
    end
    if Mode == "standard"
      assume(assum);
    else
      assume([assum assumptions]);
    end    
  catch Error
    incosistent_id = 'symbolic:property:InconsistentAssumptions';
    if strcmp(Error.identifier, incosistent_id)
      Base = MException('', error_str{:});
      Error = addCause(Base, Error);
      throwAsCaller(Error);
    end
    throw(Error);
  end
