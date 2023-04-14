function varargout = struct2vars(s)
  % ------------------------------
  % - assigns all output arguments
  %   to the values of each field
  %   of a scalar structure array
  % ------------------------------
  
  %% check the input argument
  arguments
    s (1,1) struct;
  end
  %% assign the output arguments
  nargoutchk(0, numFields(s));
  varargout = struct2cell(s);
