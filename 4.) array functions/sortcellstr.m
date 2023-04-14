function varargout = sortcellstr(a, varargin)
  % -----------------------------------------
  % - sorts a cell array of character vectors
  % -----------------------------------------
  nargoutchk(0,2);
  if ~isTextArray(a, 'cell of char')
    error('''a'' must be a cell array of character vectors');
  end
  [varargout{1:nargout}] = sort(string(a), varargin{:});
  varargout{1} = cellstr(varargout{1});
