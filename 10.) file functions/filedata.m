function ds = filedata(location, options)
  % -------------------------
  % - the FileDatastore class
  % -------------------------
  
  %% check the input arguments
  arguments
    location {mustBeText};
    options.ReadFcn function_handle = @readdoc;
    options.FileExtensions {mustBeText};
    options.IncludeSubfolders (1,1) {mustBeNumericOrLogical} = true;
  end
  %% compute the file datastore
  try
    Args = namedargs2cell(options);
    location = fileinfo(location);
    ds = fileDatastore(location, Args{:});
  catch Error
    throw(Error);
  end
