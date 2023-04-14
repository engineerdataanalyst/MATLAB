function str = fix_symunit(str) 
  % ---------------------------------------
  % - converts a string to a valid  
  %   MUPAD syntax for the symunit function
  % ---------------------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    str {mustBeText};
  end
  % check the string
  if isempty(str)
    return;
  elseif ischar(str)
    convert2char = true;
    str = string(str);
  else
    convert2char = false;
  end  
  %% fix the symunit
  for k = 1:numel(str)
    str{k} = [' ' str{k}];
    pattern = '(?<=\W)symunit[(]["''](\w*)["''][)]';
    [old start finish] = regexp(str{k}, pattern, 'match');
    for p = 1:length(old)
      new = ['symobj::unit("' old{p}(10:end-2) '")'];
      str{k} = replaceBetween(str{k}, start(p), finish(p), new);
      start = start+length(new)-length(old{p});
      finish = finish+length(new)-length(old{p});
    end  
    str{k}(1) = [];
  end
  %% convert back to the original type if necessary
  if convert2char
    str = char(str);
  end
