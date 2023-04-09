function bool = symisunique(a)
  % ---------------------------------------------
  % - a slight variation of the isunique function
  % - will return true if a symbolic array
  %   numerically contains unique values
  % ---------------------------------------------
  
  %% check the input argument
  arguments
    a sym;
  end  
  %% determine if the array has unique values
  % -------------------------------
  % - special case for empty arrays
  % -------------------------------
  a = formula(a);
  a = a(:);
  if isempty(a)
    bool = true;
    return;
  end
  % -------------------------------------------------------
  % - special case for arrays that are
  %   1.) all symbolic numbers
  %   2.) all numeric scalar multiples of a symbolic scalar
  % -------------------------------------------------------
  % check for compatible units
  compatible_units = checkUnits(sum(a), 'Compatible');
  % check the scale factor    
  [scale coeff] = scalar_parts(a);
  scale_found = any(isAlways(scale == a, 'Unknown', 'false'));
  scale_found = scale_found && ~isallsymnum(coeff);
  % check for a unique symbolic expression
  if compatible_units && isallsymnum(coeff) && ~scale_found
    % convert to consistent units first, then check the array
    [~, units] = separateUnits(coeff);
    units = unique(units, 'stable');
    units(units == 0) = [];
    if isempty(units)
      units = sym(1);
    end
    if ~all(units(1) == units) && (units(1) ~= 1)
      coeff = rewrite(coeff, units(1));
    end    
    bool = isequal(sort(coeff), unique(coeff));
    return;
  end
  % -----------------------------------
  % - general case for all other arrays
  % -----------------------------------
  for k = 1:length(a)-1
    for p = k+1:length(a)
      if isAlways(a(k) == a(p), 'Unknown', 'false')
        bool = false;
        return;
      end
    end   
  end  
  bool = true;
