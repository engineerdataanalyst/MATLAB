function [fullnames ext existing] = fileinfo(filenames)
  % -------------------------------
  % - returns the following
  %   information about an
  %   array of file names:
  % -------------------------------
  % - 1.) the full name of the file
  %      (the name along with the
  %       path to the file)
  % - 2.) the extension of the file
  % - 3.) a logical array of flags
  %       indicating if the file
  %       exists or not
  % -------------------------------
  
  %% check the input argument
  arguments
    filenames {mustBeText};
  end
  %% modify the input argument as needed
  if ischar(filenames)
    convert2char = true;
    filenames = string(filenames);
  else
    convert2char = false;
  end
  %% compute the file information
  fullnames = filenames;
  [~, ~, ext] = fileparts(filenames);
  if ischar(ext)
    ext = {ext};
  end
  existing = true(size(filenames));
  for k = 1:numel(fullnames)
    if ~isvarname(ext{k}(2:end))
      name = what(filenames{k});
      if isempty(name)
        fullnames{k} = '';
      else
        fullnames{k} = name.path;
      end
    else
      fullnames{k} = which(filenames{k});
    end
    if isempty(fullnames{k})
      fullnames{k} = filenames{k};
      existing(k) = false;
    end
  end
  %% convert back to the original type if necessary
  if convert2char
    fullnames = char(fullnames);
    ext = char(ext);
  end
