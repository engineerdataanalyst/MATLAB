function varargout = prof(varargin)
  % ----------------------
  % - the profile function
  % ----------------------
  narginchk(0,1);
  if nargin == 0
    nargouchk(0,2);
  else
    nargoutchk(0,1);
  end
  s = profile('info');  
  s.FunctionHistory = s.FunctionHistory';
  tbl = struct2table(s.FunctionTable);
  tbl.Type = categorical(tbl.Type, 'Protected', true);
  if nargin == 0
    CallMode = s.FunctionHistory(:,1);
    CallMode = categorical(CallMode, ...
                          [0 1], {'Entrance' 'Exit'}, ...
                          'Protected', true);
    CallMode = table(CallMode);
    row = s.FunctionHistory(:,2);
    his = [CallMode tbl(row,:)];
    varargout = {tbl his};
  else    
    col = {'CompleteName' 'FileName' 'Children' 'Parents' 'ExecutedLines'};
    tbl(:,col) = [];
    tbl = sortrows(tbl, 'TotalTime', 'descend');
    writetable(tbl, varargin{1});
    varargout = {};
  end
