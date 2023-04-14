function str = fix_matrix(str)
  % --------------------------------------
  % - converts a string to a valid
  %   MuPAD syntax for the matrix function
  % --------------------------------------
  
  %% check the input argument
  % check the argument class
  arguments
    str {mustBeText};
  end
  % check the string
  if isempty(str)
    return;
  elseif ischar(str)
    convert2char = true;
    str = string(str);
  else
    convert2char = false;
  end
  %% fix the matrix
  for k = 1:numel(str)
    str{k} = [' ' str{k} ' '];
    start = regexp(str{k}, '(?<=\s)[(?![)');
    for p = 1:length(start)
      [old new finish] = compute_args(str{k}, start(p));
      if ~isempty(old)
        str{k} = replaceBetween(str{k}, start(p), finish, new);
        start = start+length(new)-length(old);
      end
    end
    str{k}([1 end]) = [];
  end
  %% convert back to the original type if necessary
  if convert2char
    str = char(str);
  end
end
% =
function [old new finish] = compute_args(str, start)
  % ----------------------------
  % - computes the arguments
  %   for the piecewise function
  % ----------------------------
  
  %% compute the piecewise arguments
  Args = {};
  finish = start;
  str_len = length(str);
  while finish <= str_len && str(finish) ~= ']'
    arg_start = finish+1;
    valid_matrix = true;
    while true
      % compute the argument string
      arg_str = str(arg_start:finish);
      finish = finish+1;
      if finish <= str_len && any(str(finish) == ';]')
        % check the parentheses
        open_paren_loc = strfind(arg_str, '(');
        closed_paren_loc = strfind(arg_str, ')');
        num_open_parens = nnz(open_paren_loc);
        num_closed_parens = nnz(closed_paren_loc);
        valid_parens = num_open_parens == num_closed_parens;
        % check the brackets
        open_bracket_loc = strfind(arg_str, '[');
        closed_bracket_loc = strfind(arg_str, ']');
        num_open_brackets = nnz(open_bracket_loc);
        num_closed_brackets = nnz(closed_bracket_loc);
        valid_brackets = num_open_brackets == num_closed_brackets;
        % append the argument string to the cell array
        if valid_parens && valid_brackets
          arg_str = ['[' arg_str ']'];
          Args = [Args; {arg_str}];
          break;
        end
      elseif finish > str_len
        valid_matrix = false;
        break;
      end
    end
  end
  valid_matrix = valid_matrix && isspace(str(finish+1));
  %% compute the old and new piecewise argument strings
  if valid_matrix
    old = str(start:finish);
    args_str = ['[' repmat('%s,', 1, size(Args,1))];
    args_str(end) = ']';
    new = ['matrix(' sprintf(args_str, Args{:}) ')'];
  else
    old = '';
    new = '';
  end
end
% =
