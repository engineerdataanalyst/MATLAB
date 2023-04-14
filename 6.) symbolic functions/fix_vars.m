function str = fix_vars(str)
  % ----------------------------------
  % - converts a string to a valid
  %   MuPAD syntax for the
  %   E, I, and Re variables
  % ----------------------------------
  
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
  %% fix the variables
  for k = 1:numel(str)
    str{k} = [' ' str{k} ' '];
    str{k} = regexprep(str{k}, '(?<=\W)E(?=\W)', 'E_Var');
    str{k} = regexprep(str{k}, '(?<=\W)I(?=\W)', 'I_Var');
    str{k} = regexprep(str{k}, '(?<=\W)Re(?=\W)', 'Re_Var');
    str{k}([1 end]) = [];
  end
  %% convert back to the original type if necessary
  if convert2char
    str = char(str);
  end
end
