function bool = iscellarray(a, classname, options)
  % ---------------------------
  % - returns true if an array
  %   is a cell array
  %   and/or if an array
  %   is a cell array with
  %   array values
  %   with a specific dimension
  %   and data type
  % ---------------------------
  
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
    options.CellDim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.ValuesDim (1,:) double ...
    {mustBeNonempty, mustBeInteger, mustBeNonnegative};
    options.CheckEmptyCell (1,1) logical;
    options.CheckEmptyValues (1,1) logical;
  end
  %% compute the default mode
  ModeExists = isfield(options, 'Mode');
  CellDimExists = isfield(options, 'CellDim');
  ValuesDimExists = isfield(options, 'ValuesDim');
  CheckEmptyCellExists = isfield(options, 'CheckEmptyCell');
  CheckEmptyValuesExists = isfield(options, 'CheckEmptyValues');
  if ~ModeExists && CellDimExists && ValuesDimExists
    options.Mode = "cell and values";
  elseif ~ModeExists && CellDimExists && ~ValuesDimExists
    options.Mode = "cell";
  elseif ~ModeExists && ~CellDimExists && ValuesDimExists
    options.Mode = "values";
  elseif ~ModeExists
    options.Mode = "cell";
  end
  Mode = lower(string(options.Mode));
  options = repmat({rmfield(options, 'Mode')}, 1, 2);
  %% modify the options for the cell array
  % remove the necessary fields
  fields = string.empty;
  if ValuesDimExists
    fields = [fields "ValuesDim"];
  end
  if CheckEmptyValuesExists
    fields = [fields "CheckEmptyValues"];
  end
  if ~isempty(fields)
    options{1} = rmfield(options{1}, fields);
  end
  % rename the necessary fields
  [old_fields new_fields] = deal(string.empty);
  if CellDimExists
    old_fields = [old_fields "CellDim"];
    new_fields = [new_fields "Dim"];
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
  if CellDimExists
    fields = [fields "CellDim"];
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
  if ValuesDimExists
    old_fields = [old_fields "ValuesDim"];
    new_fields = [new_fields "Dim"];
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
    func{1} = @(arg) isArray(a, 'cell', options{1}{:});
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
      func{1} = @(arg) isArray(arg, 'cell', options{1}{:});
    end
    % second function handle
    if nargin == 1
      func{2} = @(arg) isArray(arg, options{2}{:});
    else
      func{2} = @(arg) isArray(arg, classname, options{2}{:});
    end
  end
  %% check the array
  if Mode == "cell or values"
    bool = func{1}(a) || all(cellfun(func{2}, a), 'all');
  else
    bool = func{1}(a) && all(cellfun(func{2}, a), 'all');
  end
