function bool = iscolvar(t, varargin)
  % ---------------------------
  % - returns a logical array
  %   corresponding to the
  %   elements of an array
  %   that are column variables
  %   of a table or timetable
  % ---------------------------
  
  %% check the input arguments
  arguments
    t tabular;
  end
  arguments (Repeating)
    varargin char;
  end
  %% compute the logical array
  bool = ismember(varargin, t.Properties.VariableNames);
