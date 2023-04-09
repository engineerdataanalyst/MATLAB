function bool = isTextArray(a, classname, options)
  % --------------------------
  % - returns true if an array
  %   is an array of text
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector, ...
     mustBeMemberi(classname, ["char" ...
                               "string" ...
                               "cell of char" ...
                               "cell of string" ...
                               "cell"])} = ["char" ...
                                            "string" ...
                                            "cell of char" ...
                                            "cell of string" ...
                                            "cell"];
    options.ArrayDim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.TextDim (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyArray (1,1) logical;
    options.CheckEmptyText (1,1) logical;
  end
  %% replicate the options
  options = repmat({options}, 1, 3);
  %% modify the options for the character vectors
  % remove the necessary fields
  fields = string.empty;
  if isfield(options{1}, 'ArrayDim')
    fields = [fields "ArrayDim"];
  end
  if isfield(options{1}, 'CheckEmptyArray')
    if ~isfield(options{1}, 'CheckEmptyText')
      options{1}.CheckEmptyText = options{1}.CheckEmptyArray;
    end
    fields = [fields "CheckEmptyArray"];
  end
  if ~isempty(fields)
    options{1} = rmfield(options{1}, fields);
  end
  % convert to cell array
  options{1} = namedargs2cell(options{1});
  %% modify the options for the string arrays
  options{2} = namedargs2cell(options{2});
  %% modify the options for the cell arrays
  % remove the necessary fields
  fields = string.empty;
  if isfield(options{3}, 'TextDim')
    fields = [fields "TextDim"];
  end
  if isfield(options{3}, 'CheckEmptyText')
    fields = [fields "CheckEmptyText"];
  end
  if ~isempty(fields)
    options{3} = rmfield(options{3}, fields);
  end
  % rename the necessary fields
  [old_fields new_fields] = deal(string.empty);
  if isfield(options{3}, 'ArrayDim')
    old_fields = [old_fields "ArrayDim"];
    new_fields = [new_fields "CellDim"];
  end
  if isfield(options{3}, 'CheckEmptyArray')
    old_fields = [old_fields "CheckEmptyArray"];
    new_fields = [new_fields "CheckEmptyCell"];
  end
  if ~isempty(old_fields)
    options{3} = renamefields(options{3}, old_fields, new_fields);
  end
  % convert to cell array
  options{3} = namedargs2cell(options{3});
  %% compute the test function handles
  char_case = @(arg) ischar(arg) && ...
                     isStringScalar2(string(arg), options{1}{:});
  if iscell(a)
    string_case = @(arg) isStringScalar2(arg, options{1}{:});
  else
    string_case = @(arg) isStringArray(arg, options{2}{:});
  end
  char_or_string_case = @(arg) char_case(arg) || string_case(arg);
  %% check the array
  bool = false;
  classname = unique(lower(string(classname)), 'stable');
  for k = 1:length(classname)
    % test conditions
    switch classname(k)
      case "char"
        bool = char_case(a);
      case "string"
        bool = string_case(a);
      otherwise
        if iscellarray(a, options{3}{:})
          cell_type = extractAfter(classname(k), "cell of ");
          switch cell_type
            case "char"
              bool = all(cellfun(char_case, a), 'all');
            case "string"
              bool = all(cellfun(string_case, a), 'all');
            otherwise
              bool = all(cellfun(char_or_string_case, a), 'all');
          end
        end
    end
    % breaking the loop if necessary
    if bool
      break;
    end
  end
