function a = convert2row(a)
  % ---------------------------------
  % - converts all the contents of a
  %   cell array to a row vector
  %  (ignores data types for which the
  %   reshape function is not defined)
  % ----------------------------------

  %% check the input argument
  arguments
    a cell;
  end
  %% convert the contents of the cell array to a row vector
  Args = {'ErrorHandler' @ignore_args 'UniformOutput' false};
  func = @(arg) reshape(arg, 1, []);
  a = cellfun(func, a, Args{:});
