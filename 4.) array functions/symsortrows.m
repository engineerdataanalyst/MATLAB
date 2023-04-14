function [a ind] = symsortrows(a, options)
  % ---------------------------------------------
  % - a slight variation of the sortrows function
  % - will sort the rows of a symbolic array
  %   numerically rather than how the
  %   original sortrows function normally does
  % ---------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    options.Col (1,1) double {mustBeInteger, mustBePositive} = 1;
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["ascend" ...
                                  "descend" ...
                                  "ascend unique" ...
                                  "descend unique"])} = "ascend";
  end
  % check the symbolic array
  if ~issymmatrix(a)
    error('''a'' must be a symbolic 2-D array');
  end
  % check the column dimension
  Col = options.Col;
  if (nargin > 2) && isempty(Col)
    Col = 1;
  end
  if Col > size(a, 2)
    str = stack('''Col'' must not exceed', ...
                'the number of columns of ''a''');
    error(str);
  end
  % check the sorting mode
  Mode = erase(lower(options.Mode), " unique");
  sort_ascend = Mode == "ascend";
  sort_unique = contains(options.Mode, "unique", 'IgnoreCase', true);
  %% check for an empty array
  if isEmpty(a)
    if nargout == 2
      ind = double.empty(size(a));
    end
    return;
  end
  %% temporarily convert symbolic functions to sym arrays
  if issymfun(a)
    convert2symfun = true;
    args = argnames(a);
    a = formula(a);
  else
    convert2symfun = false;
  end
  %% sort the rows of the symbolic array
  % add a dummy value to the rows of the array
  a = [ones(1, size(a,2)); a];
  v = a(:,Col);
  % compute the units of the array
  compatible_units = checkUnits(v, 'Compatible');
  units = sym.nan(size(v));
  [~, units(compatible_units)] = separateUnits(v(compatible_units));
  units(units == 0) = 1;
  % compute the unit informations for the array
  unit_infos = strings(size(v));
  unit_infos(~compatible_units) = "Incompatible";
  unit_infos(compatible_units) = unitInfos(units(compatible_units));
  unique_unit_infos = unique(unit_infos, 'stable');
  % remove any unit informations that are repetitive
  k = 1;
  while k <= length(unique_unit_infos)-1
    infok = ismember(unit_infos, unique_unit_infos(k)) & isfinite(a);
    p = k+1;
    while p <= length(unique_unit_infos)
      infop = ismember(unit_infos, unique_unit_infos(p)) & isfinite(a);
      if checkUnits(sum(a(infok))+sum(a(infop)), 'Compatible')
        unit_infos(infop) = unique_unit_infos(k);
        unique_unit_infos(p) = [];
      end
      p = p+1;
    end
    k = k+1;
  end
  % remove the dummy value from the rows array
  a(1,:) = [];
  unit_infos(1) = [];
  if ~ismember("Dimensionless", unit_infos)
    unique_unit_infos(1) = [];
  end
  % sort the rows symbolic array on the basis of each unit
  a_old = a;
  a = [];
  for k = 1:length(unique_unit_infos)
    % compute the array to sort
    loc = ismember(unit_infos, unique_unit_infos(k));
    a_new = a_old(loc,:);    
    % compute the target index function handle
    if sort_ascend
      change_ind = @(lhs, rhs) isAlways(lhs > rhs, 'Unknown', 'false');
    else
      change_ind = @(lhs, rhs) isAlways(lhs < rhs, 'Unknown', 'false');
    end
    % sort the symbolic array
    p = 1;
    while p <= size(a_new,1)
      % compute the target index
      target_ind = p;
      for t = p+1:size(a_new,1)
        if change_ind(a_new(target_ind, Col), a_new(t, Col))
          target_ind = t;
        end
      end
      % swap the target value with the left value
      a_new([p target_ind],:) = a_new([target_ind p],:);
      if sort_unique
        remove_loc = false(p,size(a_new,2));
        if p ~= size(a_new,1)
          remove_loc = [remove_loc; a_new(p,:) == a_new(p+1:end,:)];
        end
        remove_loc = all(isAlways(remove_loc), 2);
        a_new(remove_loc,:) = [];
      end
      p = p+1;
    end
    % update the sorted array
    a = [a; a_new];
  end
  %% compute the sorting indices of the array if necessary
  if nargout == 2
    ind = zeros(size(a,1), 1);
    for k = 1:size(a,1)
      if isnan(a(k,Col))
        equal = isnan(a_old(:,Col));
      else
        equal = isAlways(a(k,:) == a_old, 'Unknown', 'false');
      end
      ind(k) = find(all(equal, 2), 1);
    end
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    a(args) = a;
  end
