function num = numFields(s)
  % -----------------------------
  % - returns the number of
  %   fields in a structure array
  % -----------------------------
  
  %% check the input argument
  arguments
    s {mustBeA(s, 'struct')};
  end
  %% compute the number of fields
  num = length(fieldnames(s));
