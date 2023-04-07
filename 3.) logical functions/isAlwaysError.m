function bool = isAlwaysError(a, error_str)
  % - ----------------------------------------------
  % - a slight variation of the isAlways function
  % - will throw an error containing an input string
  %   and display a cause error returned by isAlways
  % ------------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
  end
  arguments (Repeating)
    error_str;
  end
  % check the error string
  if isempty(error_str)
    error_str = {'unable to prove the symbolic assumption(s)'};
  end
  %% call the isAlways function
  try
    bool = isAlways(a, 'Unknown', 'error');
  catch Error
    if strcmp(Error.identifier, 'symbolic:sym:isAlways:TruthUnknown')
      symbolics = cellfun(@issym, error_str);
      error_str(symbolics) = array2cellsymstr(error_str(symbolics));
      Base = MException('', error_str{:});
      Error = addCause(Base, Error);
    end
    throwAsCaller(Error);
  end
