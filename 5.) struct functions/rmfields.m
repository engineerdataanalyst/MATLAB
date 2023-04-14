function varargout = rmfields(s, fields)
  % ------------------------------
  % - a slight variation of the
  %   rmfield function
  % - will remove the fields
  %   of multiple structure arrays
  %   instead of only one
  %   structure array
  % ------------------------------
  
  %% check the input argument
  arguments (Repeating)
    s struct;
    fields {mustBeTextScalar, mustBeNonzeroLengthText};
  end
  %% return the number of fields
  for k = 1:length(s)
    varargout{k} = rmfield(s{k}, fields{k});
  end
