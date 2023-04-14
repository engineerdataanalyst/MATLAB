function s = renamefields(s, old_fields, new_fields)
  % ----------------------
  % - renames the fields
  %   of a structure array
  % ----------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    s struct;
    old_fields (1,:) {mustBeNonzeroLengthText, mustBeNonempty};
    new_fields (1,:) {mustBeNonzeroLengthText, mustBeNonempty};
  end
  % check the fields
  old_fields = string(old_fields);
  new_fields = string(new_fields);
  if ~isunique(old_fields) || ~isunique(new_fields) || ...
     ~isequallen(old_fields, new_fields)
    str = stack('''old_fields'' and ''new_fields''', ...
                'must contain unique string values and', ...
                'must have the same lengths');
    error(str);
  end
  % check for non-existent field names
  fields = string(fieldnames(s));
  old_fields_loc = ismember(old_fields, fields);
  if ~all(old_fields_loc)
    field = old_fields(~old_fields_loc);
    error(message('MATLAB:rmfield:InvalidFieldname', field{1}));
  end
  %% rename the fields of the structure array
  old_fields_loc = ismember(fields, old_fields);
  fields(old_fields_loc) = new_fields;
  s = cell2struct(struct2cell(s), fields);
