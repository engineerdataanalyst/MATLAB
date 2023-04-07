function bool = iscellscalar(a, classname, options)
  % ---------------------------
  % - returns true if an array
  %   is a cell scalar
  %   and/or if an array
  %   is a cell array with
  %   scalar values
  %   with a specific data type
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
                                  "cell or values"])} = "cell";
  end
  %% compute the default mode
  Mode = lower(string(options.Mode));
  %% compute the function handles
  func = cell(2,1);
  if Mode == "cell"
    % first function handle
    func{1} = @(arg) isScalar(a, 'cell');
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
      func{1} = @(arg) isScalar(a, 'cell');
    end
    % second function handle
    if nargin == 1
      func{2} = @isScalar;
    else
      func{2} = @(arg) isScalar(arg, classname);
    end
  end
  %% check the array
  if Mode == "cell or values"
    bool = func{1}(a) || all(cellfun(func{2}, a), 'all');
  else
    bool = func{1}(a) && all(cellfun(func{2}, a), 'all');
  end
