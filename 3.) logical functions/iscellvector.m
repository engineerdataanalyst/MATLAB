function bool = iscellvector(a, classname, options)
  % --------------------------
  % - returns true if an array
  %   is a cell vector
  %   and/or if an array
  %   is a cell array with
  %   vector values
  %   with a specific length
  %   and data type
  % --------------------------
  
  %% check the input arguments
  arguments
    a;
    classname ...
    {mustBeNonzeroLengthText, mustBeVector} = 'classname';
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["cell" ...
                                  "values" ...
                                  "cell and values" ...
                                  "cell or values"])};
    options.CellLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.ValuesLen (1,1) double {mustBeInteger, mustBeNonnegative};
    options.CheckEmptyCell (1,1) logical;
    options.CheckEmptyValues (1,1) logical;
  end
  %% compute the default mode
  ModeExists = isfield(options, 'Mode');
  CellLenExists = isfield(options, 'CellLen');
  ValuesLenExists = isfield(options, 'ValuesLen');
  CheckEmptyCellExists = isfield(options, 'CheckEmptyCell');
  CheckEmptyValuesExists = isfield(options, 'CheckEmptyValues');
  if ~ModeExists && CellLenExists && ValuesLenExists
    options.Mode = "cell and values";
  elseif ~ModeExists && CellLenExists && ~ValuesLenExists
    options.Mode = "cell";
  elseif ~ModeExists && ~CellLenExists && ValuesLenExists
    options.Mode = "values";
  elseif ~ModeExists
    options.Mode = "cell";
  end
  Mode = lower(string(options.Mode));
  options = repmat({rmfield(options, 'Mode')}, 1, 2);
  %% modify the options for the cell array
  % remove the necessary fields
  fields = string.empty;
  if ValuesLenExists
    fields = [fields "ValuesLen"];
  end
  if CheckEmptyValuesExists
    fields = [fields "CheckEmptyValues"];
  end
  if ~isempty(fields)
    options{1} = rmfield(options{1}, fields);
  end
  % rename the necessary fields
  [old_fields new_fields] = deal(string.empty);
  if CellLenExists
    old_fields = [old_fields "CellLen"];
    new_fields = [new_fields "Len"];
  end
  if CheckEmptyCellExists
    old_fields = [old_fields "CheckEmptyCell"];
    new_fields = [new_fields "CheckEmpty"];
  end
  if ~isempty(old_fields)
    options{1} = renamefields(options{1}, old_fields, new_fields);
  end
  % convert to cell array
  options{1} = namedargs2cell(options{1});
  %% modify the options for the values
  % remove the necessary fields
  fields = string.empty;
  if CheckEmptyCellExists
    fields = [fields "CheckEmptyCell"];
  end
  if CellLenExists
    fields = [fields "CellLen"];
  end
  if ~isempty(fields)
    options{2} = rmfield(options{2}, fields);
  end
  % rename the necessary fields
  [old_fields new_fields] = deal(string.empty);
  if CheckEmptyValuesExists
    old_fields = [old_fields "CheckEmptyValues"];
    new_fields = [new_fields "CheckEmpty"];
  end
  if ValuesLenExists
    old_fields = [old_fields "ValuesLen"];
    new_fields = [new_fields "Len"];
  end
  if ~isempty(old_fields)
    options{2} = renamefields(options{2}, old_fields, new_fields);
  end
  % convert to cell array
  options{2} = namedargs2cell(options{2});
  %% compute the function handles
  func = cell(2,1);
  if Mode == "cell"
    % first function handle
    func{1} = @(arg) isVector(a, 'cell', options{1}{:});
    % second function handle
    if nargin == 1
      func{2} = @(~) true;
    else
      func{2} = @(arg) isArray(arg, classname);
    end
  else
    % first function handle
    if Mode == "values"
      func{1} = @iscell;
    else
      func{1} = @(arg) isVector(arg, 'cell', options{1}{:});
    end
    % second function handle
    if nargin == 1
      func{2} = @(arg) isVector(arg, options{2}{:});
    else
      func{2} = @(arg) isVector(arg, classname, options{2}{:});
    end
  end
  %% check the array
  if Mode == "cell or values"
    bool = func{1}(a) || all(cellfun(func{2}, a), 'all');
  else
    bool = func{1}(a) && all(cellfun(func{2}, a), 'all');
  end
