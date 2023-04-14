function varargout = sortfields(s, varargin)
  % ----------------------
  % - sorts the fields
  %   of a structure array
  % ----------------------
  
  %% check the input arguments
  arguments
    s struct;
  end
  arguments (Repeating)
    varargin;
  end
  %% sort the fields of the structure array
  new_fields = sortcellstr(fieldnames(s), varargin{:});
  [varargout{1:nargout}] = orderfields(s, new_fields);
