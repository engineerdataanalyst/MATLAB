function filenames = fix_filenames(filenames, trim_underscores)
  % --------------------------------
  % - removes the path and extension
  %   to an array of file names
  %   and converts them
  %   to valid MATLAB identifiers
  % --------------------------------
  
  %% check the input arguments
  arguments
    filenames {mustBeText};
    trim_underscores {mustBeNumericOrLogical} = false;
  end
  %% fix the file names
  try
    [~, filenames] = fileparts(filenames);
    filenames = convert2identifier(filenames, trim_underscores);
  catch Error
    throw(Error);
  end
