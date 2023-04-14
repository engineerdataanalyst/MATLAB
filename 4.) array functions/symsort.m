function [a ind] = symsort(a, options)
  % --------------------------------------------
  % - a slight variation of the sort function  
  % - will sort the contents of a symbolic array
  %   numerically rather than how the
  %   original sort function normally does
  % --------------------------------------------
  
  %% check the input arguments
  % check the argument classes
  arguments
    a sym;
    options.Dim (1,1) double ...
    {mustBeInteger, mustBePositive} = default_dim(a);
    options.Mode ...
    {mustBeTextScalar, ...
     mustBeMemberi(options.Mode, ["ascend" ...
                                  "descend" ...
                                  "ascend unique" ...
                                  "descend unique"])} = "ascend";
  end
  % check the array dimension
  Dim = options.Dim;
  if ~ismember(Dim, [1 2])
    error('''Dim'' must be 1 or 2');
  end
  % check the sorting mode
  Mode = erase(lower(options.Mode), " unique");
  sort_ascend = Mode == "ascend";
  sort_unique = contains(options.Mode, "unique", 'IgnoreCase', true);
  %% check for an empty array
  if isEmpty(a)
    if nargout == 2
      [~, ind] = sort(a);
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
  %% convert the array to a column vector if sorting uniquely
  if sort_unique && ~isvector(a)
    a = a(:);
    Dim = 1;
  end      
  %% sort the symbolic array
  if (isrow(a) && Dim == 2) || (iscolumn(a) && Dim == 1)
    % add a dummy value to the of the vector
    if isrow(a)
      a = [1 a];
    else
      a = [1; a];
    end
    % compute the units of the vector
    compatible_units = checkUnits(a, 'Compatible');
    units = sym.nan(size(a));
    [~, units(compatible_units)] = separateUnits(a(compatible_units));
    units(units == 0) = 1;
    % compute the unit informations for the vector
    unit_infos = strings(size(a));
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
    % remove the dummy value from the vector
    a(1) = [];
    unit_infos(1) = [];
    if ~ismember("Dimensionless", unit_infos)
      unique_unit_infos(1) = [];
    end
    % sort the symbolic vector on the basis of each unit
    a_old = a;
    a = [];
    for k = 1:length(unique_unit_infos)
      % check for compatible units
      loc = ismember(unit_infos, unique_unit_infos(k));
      a_new = a_old(loc);
      compatible_units = checkUnits(sum(a_new), 'Compatible');
      % check the scale factor
      [scale coeff] = scalar_parts(a_new);
      scale_found = any(isAlways(scale == a_new, 'Unknown', 'false'));
      scale_found = scale_found && ~isallsymnum(coeff);
      % sort the symbolic vector
      if compatible_units && isallsymnum(coeff) && ~scale_found
        % --------------------------------
        % - special case for the following
        %   vectors with compatible units
        % --------------------------------
        % 1.) vectors that are all
        %     symbolic numbers
        % 2.) vectors that are all
        %     numeric scalar multiples
        %     of a symbolic scalar
        % --------------------------------
        % convert to consistent units
        [a_unsorted units] = separateUnits(coeff);
        units = unique(units, 'stable');
        units(units == 0) = [];
        if isempty(units)
          units = sym(1);
        end
        if ~all(units(1) == units) && (units(1) ~= 1)
          coeff = rewrite(coeff, units(1));
          a_unsorted = separateUnits(coeff);
        end
        % sort the symbolic vector
        a_unsorted = double(a_unsorted);
        if sort_unique
          [~, ind_new] = unique(a_unsorted);
          if ~sort_ascend
            ind_new = flip(ind_new);
          end
        else
          [~, ind_new] = sort(a_unsorted, Mode);
        end
        if isAlways(scale < 0)
          ind_new = flip(ind_new);
        end
        a_new = a_new(ind_new);
      else
        % ------------------------------------
        % - general case for all other vectors
        % ------------------------------------
        % function handle for computing the target indices
        if sort_ascend
          change_ind = @(lhs, rhs) isAlways(lhs > rhs);
        else
          change_ind = @(lhs, rhs) isAlways(lhs < rhs);
        end
        % sort the symbolic vector
        p = 1;
        while p <= length(a_new)
          % compute the target index
          target_ind = p;
          for t = p+1:length(a_new)
            if change_ind(a_new(target_ind), a_new(t))
              target_ind = t;
            end
          end
          % swap the target value with the left value
          a_new([p target_ind]) = a_new([target_ind p]);
          if sort_unique
            if isrow(a_new)
              remove_loc = [false(1,p), a_new(p) == a_new(p+1:end)];
            else
              remove_loc = [false(p,1); a_new(p) == a_new(p+1:end)];
            end
            remove_loc = isAlways(remove_loc);
            a_new(remove_loc) = [];
          end
          p = p+1;
        end
      end
      % update the sorted vector
      if isrow(a_old)
        a = [a a_new];
      else
        a = [a; a_new];
      end
    end
    % compute the sorting indices of the vector if necessary
    if nargout == 2
      ind = zeros(size(a));
      for k = 1:length(a)
        if isnan(a(k))
          equal = isnan(a_old);
        else
          equal = isAlways(a(k) == a_old, 'Unknown', 'false');
        end
        ind(k) = find(equal, 1);
      end
    end
  elseif (Dim == 1) && ~isvector(a)
    % sort each column of the symbolic array
    if ismatrix(a)
      a_size = [size(a) 1];
    else
      a_size = size(a);
    end
    ind = zeros(a_size);    
    for k = 1:prod(a_size(3:end))
      for p = 1:width(a)
        [a(:,p,k) ind(:,p,k)] = symsort(a(:,p,k), 'Mode', Mode);
      end
    end
  elseif ~isvector(a)
    % sort each row of the symbolic array
    if ismatrix(a)
      a_size = [size(a) 1];
    else
      a_size = size(a);
    end
    ind = zeros(size(a));    
    for k = 1:prod(a_size(3:end))
      for p = 1:height(a)
        [a(p,:,k) ind(p,:,k)] = symsort(a(p,:,k), 'Mode', Mode);
      end
    end  
  end
  %% convert back to symbolic function if necessary
  if convert2symfun
    a(args) = a;
  end
end
% =
function Dim = default_dim(a)
  % ---------------------------------
  % - helper function for determining
  %   the default dimension for
  %   the symbolic array
  % ---------------------------------
  if isScalar(a)
    Dim = 1;
  else
    Dim = find(Size(a) ~= 1, 1);
  end
end
% =
