function bool = symismember(a, b)
  % ----------------------------------------------
  % - a slight variation of the ismember function
  % - will first convert all compatible units
  %   of a symbolic expresssion to the same units,
  %   then will numerically execute
  %   the ismember function
  % ----------------------------------------------
  
  %% check the input arguments
  arguments
    a sym;
    b sym;
  end
  %% find the location of the elements in 'a' that are in 'b'
  % -------------------------------
  % - special case for empty arrays  
  % -------------------------------
  a = formula(a);
  b = formula(b);
  if isempty(a) || isempty(b)
    bool = ismember(a, b);
    return;
  end
  % -------------------------------------------------------
  % - special case for arrays that are
  %   1.) all symbolic numbers
  %   2.) all numeric scalar multiples of a symbolic scalar  
  % -------------------------------------------------------
  % convert the arrays to consistent units  
  [a_scale a_coeff] = scalar_parts(a);
  [b_scale b_coeff] = scalar_parts(b);
  compatible_units = checkUnits(sum(a(:))+sum(b(:)), 'Compatible');
  if compatible_units
    [~, a_units] = separateUnits(a_coeff);
    [~, b_units] = separateUnits(b_coeff);
    a_units = unique(a_units, 'stable');
    b_units = unique(b_units, 'stable');
    a_units(a_units == 0) = [];
    b_units(b_units == 0) = [];
    if isempty(a_units)
      a_units = sym(1);
    end
    if isempty(b_units)
      b_units = sym(1);
    end
    if ~all(a_units(1) == a_units) && (a_units(1) ~= 1)
      a_coeff = rewrite(a_coeff, a_units(1));      
    end
    if ~all(a_units(1) == b_units) && (a_units(1) ~= 1)
      b_coeff = rewrite(b_coeff, a_units(1));
    end
  end
  % check the scale factors
  equal_scale = isAlways(a_scale == b_scale, 'Unknown', 'false');
  a_scale_found = any(isAlways(a_scale == a, 'Unknown', 'false'), 'all');
  b_scale_found = any(isAlways(b_scale == b, 'Unknown', 'false'), 'all');
  a_scale_found = a_scale_found && ~isallsymnum(a_coeff);
  b_scale_found = b_scale_found && ~isallsymnum(b_coeff);
  % call the ismember function on the coefficients
  symnum_coeff = isallsymnum(a_coeff) && isallsymnum(b_coeff);
  scale_found = a_scale_found || b_scale_found;
  if equal_scale && symnum_coeff && ~scale_found
    bool = ismember(a_coeff, b_coeff);
    return;
  end
  % -----------------------------------
  % - general case for all other arrays
  % -----------------------------------
  bool = false(size(a));
  for k = 1:numel(a)
    for p = 1:numel(b)
      if isAlways(a(k) == b(p), 'Unknown', 'false')
        bool(k) = true;
        break;
      end
    end
  end
