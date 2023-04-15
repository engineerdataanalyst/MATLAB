%% datastore data
folder_names = {'mlb'; 'nfl'};
location = fileinfo(folder_names{:});

%% MLB datastore
mlb = fileDatastore(location{1}, 'ReadFcn', @task, ...
                    'FileExtensions', '.xlsx');

%% NFL datastore
nfl = fileDatastore(location{2}, 'ReadFcn', @task, ...
                    'FileExtensions', '.xlsx');

%% MLB datastruct
if (exist('S', 'var') ~= 1) || ...
  ((exist('S', 'var') == 1) && ...
   (~isstruct(S) || ~isequal(fieldnames(S), folder_names)))
  S = default_struct(folder_names{:});
end
S.mlb = ds_struct(mlb);

%% NFL datastruct
if (exist('S', 'var') ~= 1) || ...
  ((exist('S', 'var') == 1) && ...
   (~isstruct(S) || ~isequal(fieldnames(S), folder_names)))
  S = default_struct(folder_names{:});
end
S.nfl = ds_struct(nfl);

%% player task function
function t = task(filename)
  t = readtable(filename, 'ReadRowNames', true);
  t.Team = categorical(t.Team);
  t.League = categorical(t.League);
end
