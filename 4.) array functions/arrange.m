function anew = arrange(a, field, mode)
  % ----------------------------
  % - arrange the contents
  %   in a struct/table 'a'
  %   by 'field' in 'mode' order
  % ----------------------------
  if ~isstructvector(a) && ~istabular(a)
    str = stack('first argument must be:', ...
                '-----------------------', ...
                '1.) a struct vector', ...
                '2.) a table', ...
                '3.) a timetable');
    error(str);
  end
  if istabular(a)
    props = a.Properties;
    anew = table2struct(a);
  else
    anew = a;
  end  
  n = length(anew);
  for start = 1:n-1
    info = anew(start).(field);
    index = start;
    for loc = start:n
      switch mode
        case 'ascend'
          if isgreater(info, anew(loc).(field))
            info = anew(loc).(field);
            index = loc;
          end
        case 'descend'
          if islesser(info, anew(loc).(field))
            info = anew(loc).(field);
            index = loc;
          end
        otherwise
          str = stack('sorting mode must be', ...
                      'one of these strings:', ...
                      '---------------------', ...
                      '1.) ''ascend''', ...
                      '2.) ''descend''');
          error(str);
      end
    end
    anew([start index]) = anew([index start]);
  end
  if istabular(a)
    anew = struct2table(anew);
    anew.Properties = props;
  end
